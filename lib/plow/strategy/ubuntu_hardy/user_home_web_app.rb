# encoding: UTF-8

class Plow
  class Strategy
    class UbuntuHardy
      
      class UserHomeWebApp
        attr_reader :context, :users_file_name, :vhost_file_name
        attr_reader :user_home, :site_home, :app_home
        
        def initialize(context)
          @context         = context
          @users_file_name = "/etc/passwd"
          @vhost_file_name = "/etc/apache2/sites-available/#{context.site_name}.conf"
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
        
        def read_users_data(&block)
          File.readlines(users_file_name).each do |user_line|
            yield user_line.split(':')
          end
        end
        
        ############################################################################################################
        
        def system_account_exists?
          read_users_data do |user_data|
            user_name = user_data[0]
            user_id   = user_data[2]
            
            if user_name == context.user_name
              raise Plow::ReservedSystemUserNameError unless user_id >= 1000
              return true
            end
          end
          
          return false
        end
        
        def create_system_account
          say "adduser #{context.user_name}"
        end
        
        ############################################################################################################
        
        def system_account_home_exists?
          read_users_data do |user_data|
            user_name = user_data[0]
            user_home = user_data[5]
            
            if user_name == context.user_name
              if Dir.exists?(user_home)
                return true
              else
                @user_home = user_home
                return false
              end
            end
          end
          
          raise Plow::SystemUserNameNotFoundError
        end
        
        def create_system_account_home
          say "mkdir #{user_home}"
          say "chown #{context.user_name}:#{context.user_name} #{user_home}"
        end
        
        ############################################################################################################
        
        def system_account_sites_home_exists?
          @sites_home = "#{user_home}/sites"
          Dir.exists?(sites_home)
        end
        
        def create_system_account_sites_home
          say "mkdir #{sites_home}"
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
