# encoding: UTF-8

class Plow
  class Strategy
    class UbuntuHardy
      
      class UserHomeWebApp
        attr_reader :context, :users_file_path, :vhost_file_name, :vhost_file_path, :vhost_template_file_path
        attr_reader :user_home_path, :sites_home_path, :app_root_path, :app_public_path, :app_log_path
        
        def initialize(context)
          @context         = context
          @users_file_path = "/etc/passwd"
          @vhost_file_name = "#{context.site_name}.conf"
          @vhost_file_path = "/etc/apache2/sites-available/#{vhost_file_name}"
          
          @vhost_template_file_path = "#{File.dirname(__FILE__)}/templates/apache2-vhost.conf"
        end
        
        def execute
          if user_exists?
            say "existing #{context.user_name} user"
          else
            say "creating #{context.user_name} user"
            create_user
          end
          
          if user_home_exists?
            say "existing #{user_home_path}"
          else
            say "creating #{user_home_path}"
            create_user_home
          end
          
          if sites_home_exists?
            say "existing #{sites_home_path}"
          else
            say "creating #{sites_home_path}"
            create_sites_home
          end
          
          if app_root_exists?
            raise(Plow::AppHomeAlreadyExistsError, app_root_path)
          else
            say "creating #{app_root_path}"
            create_app_root
          end
          
          @app_public_path = "#{app_root_path}/public"
          say "creating #{@app_public_path}"
          create_app_public
          
          @app_log_path = "#{app_root_path}/log"
          say "creating #{app_log_path}"
          create_app_logs
          
          if vhost_config_exists?
            raise(Plow::ConfigFileAlreadyExistsError, vhost_file_path)
          else
            say "creating #{vhost_file_path}"
            create_vhost_config
          end
          
          say "installing #{vhost_file_path}"
          install_vhost_config
        end
        
        ############################################################################################################
        
        private
        
        def say(message)
          context.say(message)
        end
        
        def users(&block)
          File.readlines(users_file_path).each do |user_line|
            user_line = user_line.chomp.split(':')
            user = {
              :name       => user_line[0],
              :password   => user_line[1],
              :id         => user_line[2].to_i,
              :group_id   => user_line[3].to_i,
              :info       => user_line[4],
              :home_path  => user_line[5],
              :shell_path => user_line[6]
            }
            yield user
          end
        end
        
        def shell(commands)
          commands.each_line do |command|
            command.strip!
            system(command) unless command.blank?
          end
        end
        
        ############################################################################################################
        
        def user_exists?
          users do |user|
            if user[:name] == context.user_name
              unless user[:id] >= 1000 && user[:id] != 65534
                raise(Plow::ReservedSystemUserNameError, context.user_name)
              end
              return true
            end
          end
          
          return false
        end
        
        def create_user
          shell "adduser #{context.user_name}"
        end
        
        ############################################################################################################
        
        def user_home_exists?
          users do |user|
            if user[:name] == context.user_name
              @user_home_path = user[:home_path]
              return Dir.exists?(user[:home_path])
            end
          end
          
          raise(Plow::SystemUserNameNotFoundError, context.user_name)
        end
        
        def create_user_home
          shell <<-RUN
            mkdir #{user_home_path}
            chown #{context.user_name}:#{context.user_name} #{user_home_path}
          RUN
        end
        
        ############################################################################################################
        
        def sites_home_exists?
          @sites_home_path = "#{user_home_path}/sites"
          Dir.exists?(sites_home_path)
        end
        
        def create_sites_home
          shell <<-RUN
            mkdir #{sites_home_path}
            chown #{context.user_name}:#{context.user_name} #{sites_home_path}
          RUN
        end
        
        ############################################################################################################
        
        def app_root_exists?
          @app_root_path = "#{sites_home_path}/#{context.site_name}"
          Dir.exists?(app_root_path)
        end
        
        def create_app_root
          shell <<-RUN
            mkdir #{app_root_path}
            chown #{context.user_name}:#{context.user_name} #{app_root_path}
          RUN
        end
        
        ############################################################################################################
        
        def create_app_public
          shell <<-RUN
            mkdir #{app_public_path}
            touch #{app_public_path}/index.html
            chown -R #{context.user_name}:#{context.user_name} #{app_public_path}
          RUN
        end
        
        ############################################################################################################
        
        def create_app_logs
          shell <<-RUN
            mkdir #{app_log_path}
            mkdir #{app_log_path}/apache2
            chmod 750 #{app_log_path}/apache2
            
            touch #{app_log_path}/apache2/access.log
            touch #{app_log_path}/apache2/error.log
            
            chmod 640 #{app_log_path}/apache2/*.log
            chown -R #{context.user_name}:#{context.user_name} #{app_log_path}
            chown root -R #{app_log_path}/apache2
          RUN
        end
        
        ############################################################################################################
        
        def vhost_config_exists?
          Dir.exists?(vhost_file_path)
        end
        
        def create_vhost_config
          File.open(vhost_file_path, 'wt') do |file|
            template_context = {
              :site_name       => context.site_name,
              :site_aliases    => context.site_aliases,
              :app_public_path => app_public_path,
              :app_log_path    => app_log_path
            }
            
            config = context.evaluate_template(vhost_template_file_path, template_context)
            file.write(config)
          end
        end
        
        ############################################################################################################
        
        def install_vhost_config
          shell <<-RUN
            a2ensite #{vhost_file_name}
            apache2ctl graceful
          RUN
        end
      end
      
    end
  end
end
