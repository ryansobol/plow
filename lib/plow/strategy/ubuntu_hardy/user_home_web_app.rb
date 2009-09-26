# encoding: UTF-8

class Plow
  class Strategy
    class UbuntuHardy
      
      class UserHomeWebApp
        attr_reader :context, :users_file_path, :vhost_file_path
        attr_reader :user_home, :sites_home, :app_home
        
        def initialize(context)
          @context         = context
          @users_file_path = "/etc/passwd"
          @vhost_file_path = "/etc/apache2/sites-available/#{context.site_name}.conf"
        end
        
        def execute
          if system_account_exists?
            say "System account already exists... skipping"
          else
            say "Creating system account..."
            create_system_account
          end
          
          if system_account_home_exists?
            say "System account home already exists... skipping"
          else
            say "Creating system account home..."
            create_system_account_home
          end
          
          if system_account_sites_home_exists?
            say "System account sites home already exists... skipping"
          else
            say "Creating system account sites home..."
            create_system_account_sites_home
          end
          
          @app_home = "#{sites_home}/#{context.site_name}"
          
          ## we can now safely assume that the following instance variables are valid
          ## @user_home, @site_home, @app_home
          
          build_app_home
          build_app_logs
          
          config = generate_virtual_host_configuration
          install_virtual_host_configuration(config)
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
        
        ############################################################################################################
        
        def system_account_exists?
          system_accounts do |account|
            if account[:user_name] == context.user_name
              unless account[:user_id] >= 1000 && account[:user_id] != 65534
                raise Plow::ReservedSystemUserNameError
              end
              return true
            end
          end
          
          return false
        end
        
        def create_system_account
          system("adduser #{context.user_name}")
        end
        
        ############################################################################################################
        
        def system_account_home_exists?
          system_accounts do |account|
            if account[:user_name] == context.user_name
              if Dir.exists?(account[:home_path])
                return true
              else
                @user_home = account[:home_path]
                return false
              end
            end
          end
          
          raise Plow::SystemUserNameNotFoundError
        end
        
        def create_system_account_home
          system("mkdir #{user_home}")
          system("chown #{context.user_name}:#{context.user_name} #{user_home}")
        end
        
        ############################################################################################################
        
        def system_account_sites_home_exists?
          @sites_home = "#{user_home}/sites"
          Dir.exists?(sites_home)
        end
        
        def create_system_account_sites_home
          system("mkdir #{sites_home}")
          system("chown #{context.user_name}:#{context.user_name} #{sites_home}")
        end
        
        ############################################################################################################
        
        def build_app_home
          commands = <<-EOS
            mkdir #{app_home}
            mkdir #{app_home}/public
            
            touch #{app_home}/public/index.html
            
            chown -R #{context.user_name}:#{context.user_name} #{app_home}
          EOS
          
          commands.each_line do |command|
            say(command)
          end
        end
        
        def build_app_logs
          commands = <<-EOS
            mkdir #{app_home}/log
            mkdir #{app_home}/log/apache2
            chmod 750 #{app_home}/log/apache2
            
            touch #{app_home}/log/apache2/access.log
            touch #{app_home}/log/apache2/error.log
            chmod 640 *.log
            
            chown -R #{context.user_name}:#{context.user_name} #{app_home}/log
            chown root -R #{app_home}/log/apache2
          EOS
          
          commands.each_line do |command|
            say(command)
          end
        end
        
        ############################################################################################################
        
        def generate_virtual_host_configuration
          template_file_name = 'apache2-vhost.conf'
          template_contents  = File.read(File.join(template_pathname, file_name))
                    
          template_context = {
            :site_name    => context.site_name,
            :site_aliases => context.site_aliases,
            :app_home     => apphome
          }
          
          context.evaluate_template(template_contents, template_context)
        end
        
        def install_virtual_host_configuration(config)
          say("touch #{vhost_file_name}")
          File.open(vhost_file_name, 'wt') { |f| f.write(config) }
          say("a2siteen #{context.site_name}")
        end
        
        def restart_web_server
          say("apache2ctl graceful")
        end
      end
      
    end
  end
end
