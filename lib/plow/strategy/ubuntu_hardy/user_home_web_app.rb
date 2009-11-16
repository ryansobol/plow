# encoding: UTF-8

class Plow
  class Strategy
    class UbuntuHardy
      # Plowing strategy, compatible with the Linux Ubuntu Hardy Heron distribution, for generating
      # a web-site within a user home directory.
      class UserHomeWebApp
        attr_reader :context, :users_file_path, :vhost_file_name, :vhost_file_path, :vhost_template_file_path
        attr_reader :user_home_path, :sites_home_path, :app_root_path, :app_public_path, :app_log_path
        
        # @param [Plow::Generator] context A context reference to the generator controller. (i.e. Strategy pattern)
        #
        # @example
        #   class Plow
        #     class Generator
        #       def initialize
        #         @strategy = Plow::Strategy::UbuntuHardy::UserHomeWebApp.new(self)
        #       end
        #     end
        #   end
        def initialize(context)
          @context         = context
          @users_file_path = "/etc/passwd"
          @vhost_file_name = "#{context.site_name}.conf"
          @vhost_file_path = "/etc/apache2/sites-available/#{vhost_file_name}"
          
          @vhost_template_file_path = "#{File.dirname(__FILE__)}/templates/apache2-vhost.conf"
        end
        
        # Begins executing this strategy.  In addition to the following exceptions, this method may
        #   also raise exceptions found in private methods of this class.
        #
        # @raise [Plow::AppRootAlreadyExistsError] Raised if the web-app root path directory
        #   aleady exists
        # @raise [Plow::ConfigFileAlreadyExistsError] Raised if a apache2 vhost configuration file
        #   cannot be found
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
            raise(Plow::AppRootAlreadyExistsError, app_root_path)
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
        
        # Proxy method to `Plow::Generator#say`
        # @param [String] message A user output message
        def say(message)
          context.say(message)
        end
        
        # Proxy method to `Plow::Generator#shell`
        # @param [String] commands Shell commands with multi-line support.
        def shell(commands)
          context.shell(commands)
        end
        
        # Reads the file at `users_file_path` and yields each user iteratively.
        #
        #
        # @yield [Hash] Each user account
        # @example
        #   users do |user|
        #     user[:name]        #=> [String] The name
        #     user[:password]    #=> [String] The bogus password
        #     user[:id]          #=> [Number] The uid number
        #     user[:group_ip]    #=> [Number] The gid number
        #     user[:info]        #=> [String] General account info
        #     user[:home_path]   #=> [String] The path to the home directory
        #     user[:shell_path]  #=> [String] The path to the default shell
        #   end
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
        
        ############################################################################################################
        
        # Determines if the context.user_name already exists or not
        # 
        # @return [Boolean] `true` if found otherwise `false`
        # @raise [Plow::ReservedSystemUserNameError] Raised if the `context.user_name` is a reserved
        #   system user name
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
        
        # Creates a system user account for `context.user_name`
        def create_user
          shell "adduser #{context.user_name}"
        end
        
        ############################################################################################################
        
        # Determines if a home path for the `context.user_name` already exists
        #
        # @return [Boolean] `true` if the path already exists, otherwise `false`
        # @raise [Plow::SystemUserNameNotFoundError] Raised if the `context.user_name` is not found 
        #   even after it has been created
        def user_home_exists?
          users do |user|
            if user[:name] == context.user_name
              @user_home_path = user[:home_path]
              return Dir.exists?(user[:home_path])
            end
          end
          
          raise(Plow::SystemUserNameNotFoundError, context.user_name)
        end
        
        # Creates a `user_home_path`
        def create_user_home
          shell <<-RUN
            mkdir #{user_home_path}
            chown #{context.user_name}:#{context.user_name} #{user_home_path}
          RUN
        end
        
        ############################################################################################################
        
        # Determines if the `sites_home_path` already exists.  As a side-effect, also correctly
        #   sets the `@sites_home_path` variable.
        # @return [Boolean] `true` if the path already exists, otherwise `false`
        def sites_home_exists?
          @sites_home_path = "#{user_home_path}/sites"
          Dir.exists?(sites_home_path)
        end
        
        # Creates the `site_home_path`
        def create_sites_home
          shell <<-RUN
            mkdir #{sites_home_path}
            chown #{context.user_name}:#{context.user_name} #{sites_home_path}
          RUN
        end
        
        ############################################################################################################
        
        # Determines if the `app_root_path` already exists.  As a side-effect, also correctly
        #   sets the `@app_root_path` variable.
        # @return [Boolean] `true` if the path exists, otherwise `false`
        def app_root_exists?
          @app_root_path = "#{sites_home_path}/#{context.site_name}"
          Dir.exists?(app_root_path)
        end
        
        # Creates the `app_root_path`
        def create_app_root
          shell <<-RUN
            mkdir #{app_root_path}
            chown #{context.user_name}:#{context.user_name} #{app_root_path}
          RUN
        end
        
        ############################################################################################################
        
        # Creates the app public structure at `app_public_path`
        def create_app_public
          shell <<-RUN
            mkdir #{app_public_path}
            touch #{app_public_path}/index.html
            chown -R #{context.user_name}:#{context.user_name} #{app_public_path}
          RUN
        end
        
        ############################################################################################################
        
        # Creates the app log structure at `app_log_path`
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
        
        # Determines if the apache2 vhost config file already exists
        # @return [Boolean] `true` if the file exists, otherwise `false`
        def vhost_config_exists?
          Dir.exists?(vhost_file_path)
        end
        
        # Creates an apache2 vhost config file from a template file to a `vhost_file_path`
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
        
        # Installs the apache2 vhost config file by enabling the site and restarting the web server
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
