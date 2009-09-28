# encoding: UTF-8

class Plow
  class Strategy
    class UbuntuHardy
      
      class UserHomeWebApp
        attr_reader :context, :users_file_path, :vhost_file_name, :vhost_file_path
        attr_reader :user_home_path, :sites_home_path, :app_root_path, :app_public_path, :app_log_path
        
        def initialize(context)
          @context         = context
          @users_file_path = "/etc/passwd"
          @vhost_file_name = "#{context.site_name}.conf"
          @vhost_file_path = "/etc/apache2/sites-available/#{vhost_file_name}"
        end
        
        def execute
          if user_exists?
            say "System account (#{context.user_name}) already exists... skipping"
          else
            say "Creating system account for #{context.user_name}..."
            create_user
          end
          
          if user_home_exists?
            say "System account home (#{user_home_path}) already exists... skipping"
          else
            say "Creating system account home (#{user_home_path})..."
            create_user_home
          end
          
          if sites_home_exists?
            say "System account sites home (#{sites_home_path}) already exists... skipping"
          else
            say "Creating system account sites home (#{sites_home_path})..."
            create_sites_home
          end
          
          if app_root_exists?
            raise(Plow::AppHomeAlreadyExistsError, app_root_path)
          else
            say "Creating the application home in #{app_root_path}"
            create_app_root
          end
          
          @app_public_path = "#{app_root_path}/public"
          say "Building the application public structure in #{@app_public_path}..."
          create_app_public
          
          @app_log_path = "#{app_root_path}/log"
          say "Creating the application log structure in #{app_log_path}..."
          create_app_logs

          say "Generating the apache2 configuration from a template..."
          config = generate_virtual_host_configuration
          
          say "Installing configuration file to #{vhost_file_path}..."
          install_virtual_host_configuration(config)
          
          say "Restarting apache2..."
          restart_web_server
        end
        
        ############################################################################################################
        
        private
        
        def say(message)
          context.say(message)
        end
        
        def system_accounts(&block)
          File.readlines(users_file_path).each do |user_line|
            user_line = user_line.chomp.split(':')
            user_hash = {
              :user_name  => user_line[0],
              :password   => user_line[1],
              :user_id    => user_line[2].to_i,
              :group_id   => user_line[3].to_i,
              :user_info  => user_line[4],
              :home_path  => user_line[5],
              :shell_path => user_line[6]
            }
            yield user_hash
          end
        end
        
        def execute_lines(commands)
          commands.each_line do |command|
            command.strip!
            system(command) unless command.blank?
          end
        end
        
        ############################################################################################################
        
        def user_exists?
          system_accounts do |account|
            if account[:user_name] == context.user_name
              unless account[:user_id] >= 1000 && account[:user_id] != 65534
                raise(Plow::ReservedSystemUserNameError, context.user_name)
              end
              return true
            end
          end
          
          return false
        end
        
        def create_user
          execute_lines("adduser #{context.user_name}")
        end
        
        ############################################################################################################
        
        def user_home_exists?
          system_accounts do |account|
            if account[:user_name] == context.user_name
              @user_home_path = account[:home_path]
              return Dir.exists?(account[:home_path])
            end
          end
          
          raise(Plow::SystemUserNameNotFoundError, context.user_name)
        end
        
        def create_user_home
          execute_lines(<<-LINES)
            mkdir #{user_home_path}
            chown #{context.user_name}:#{context.user_name} #{user_home_path}
          LINES
        end
        
        ############################################################################################################
        
        def sites_home_exists?
          @sites_home_path = "#{user_home_path}/sites"
          Dir.exists?(sites_home_path)
        end
        
        def create_sites_home
          execute_lines(<<-LINES)
            mkdir #{sites_home_path}
            chown #{context.user_name}:#{context.user_name} #{sites_home_path}
          LINES
        end
        
        ############################################################################################################
        
        def app_root_exists?
          @app_root_path = "#{sites_home_path}/#{context.site_name}"
          Dir.exists?(app_root_path)
        end
        
        def create_app_root
          execute_lines(<<-LINES)
            mkdir #{app_root_path}
            chown #{context.user_name}:#{context.user_name} #{app_root_path}
          LINES
        end
        
        ############################################################################################################
        
        def create_app_public
          execute_lines(<<-LINES)
            mkdir #{app_public_path}
            touch #{app_public_path}/index.html
            chown -R #{context.user_name}:#{context.user_name} #{app_public_path}
          LINES
        end
        
        ############################################################################################################
        
        def create_app_logs
          execute_lines(<<-LINES)
            mkdir #{app_log_path}
            mkdir #{app_log_path}/apache2
            chmod 750 #{app_log_path}/apache2
            
            touch #{app_log_path}/apache2/access.log
            touch #{app_log_path}/apache2/error.log
            
            chmod 640 #{app_log_path}/apache2/*.log
            chown -R #{context.user_name}:#{context.user_name} #{app_log_path}
            chown root -R #{app_log_path}/apache2
          LINES
        end
        
        ############################################################################################################
        
        def generate_virtual_host_configuration
          template_file_name = 'apache2-vhost.conf'
          template_contents  = File.read(File.join(context.template_pathname, template_file_name))
          
          template_context = {
            :site_name       => context.site_name,
            :site_aliases    => context.site_aliases,
            :app_public_path => app_public_path,
            :app_log_path    => app_log_path
          }
          
          context.evaluate_template(template_contents, template_context)
        end
        
        def install_virtual_host_configuration(config)
          system("touch #{vhost_file_path}")
          File.open(vhost_file_path, 'wt') { |f| f.write(config) }
          system("a2ensite #{vhost_file_name}")
        end
        
        ############################################################################################################
        
        def restart_web_server
          system("apache2ctl graceful")
        end
      end
      
    end
  end
end
