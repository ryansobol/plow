# encoding: UTF-8

begin
  require 'erubis'
rescue LoadError
  abort <<-ERROR
Unexpected LoadError exception caught in #{__FILE__} on #{__LINE__}

This file depends on the erubis library, which is not available.
You may install the library via rubygems with: sudo gem install erubis -r    
  ERROR
end

class Plow
  class Generator
    attr_accessor :user_name, :site_name, :site_aliases
    
    attr_accessor :template_pathname
    
    def initialize(user_name, site_name, *site_aliases)
      if user_name.blank? || user_name.include?(' ')
        raise(Plow::InvalidSystemUserNameError, user_name)
      end
      
      if site_name.blank? || site_name.include?(' ')
        raise(Plow::InvalidWebSiteNameError, site_name)
      end
      
      site_aliases.each do |site_alias|
        if site_alias.blank? || site_alias.include?(' ')
          raise(Plow::InvalidWebSiteAliasError, site_alias)
        end
      end
      
      self.user_name    = user_name
      self.site_name    = site_name
      self.site_aliases = site_aliases
      
      self.template_pathname = File.dirname(__FILE__) + '/templates'
    end
    
    def run!
      raise Plow::NonRootProcessOwnerError unless Process.uid == 0
      
      ensure_system_account_exists
      ensure_system_account_home_exists
      ensure_system_account_sites_home_exists
      
      build_app_home
      build_app_logs
      
      generate_virtual_host_configuration
      install_virtual_host_configuration
      restart_web_server
    end
    
    private
    
    def ensure_system_account_exists
      unless SystemAccount.user_exists?(user_name)
        system("sudo adduser #{user_name}")
        puts "[TRACTOR] I hope you wrote down the password for #{user_name}..."
      end
    end

    def ensure_system_account_home_exists
      user_home = SystemAccount.home_directory_for(user_name)
      unless Dir.exists?(user_home)
        system("mkdir #{user_home}")
      end
    end
    
    def ensure_system_account_sites_home_exists
      sites_home = "#{user_home}/sites"
      unless Dir.exists?(sites_home)
        system("mkdir #{sites_home}") 
      end
    end
    
    def build_app_home
      app_home = "#{sites_home}/#{site_name}"
      commands = <<-EOS
        mkdir #{app_home}
        mkdir #{app_home}/public
        
        touch #{app_home}/public/index.html
        
        sudo chown -R #{user_name}:#{user_name} #{app_home}
      EOS
      
      commands.each_line do |command|
        system(command)
      end
    end
    
    def build_app_logs
      app_home = "#{sites_home}/#{site_name}"
      commands = <<-EOS
        mkdir #{app_home}/log
        mkdir #{app_home}/log/apache2
        chmod 750 #{app_home}/log/apache2

        touch #{app_home}/log/apache2/access.log
        touch #{app_home}/log/apache2/error.log
        chmod 640 *.log
        
        sudo chown -R #{user_name}:#{user_name} #{app_home}/log
        sudo chown root -R #{app_home}/log/apache2
      EOS
      
      commands.each_line do |command|
        system(command)
      end
    end
    
    def generate_virtual_host_configuration
      template_file_name = 'apache2-vhost.conf'
      template_contents  = File.read(File.join(template_pathname, template_file_name))
      template           = Erubis::Eruby.new(template_contents)
      
      context = {
        :site_name    => site_name,
        :site_aliases => site_aliases,
        :app_home     => apphome
      }
      output = template.evaluate(context)
    end
    
    def install_virtual_host_configuration
      virtual_host_file = "/etc/apache2/sites-available/#{site_name}.conf"
      system("sudo touch #{virtual_host_file}")
      File.open(virtual_host_file, 'wt') { |f| f.write(output) }
    end
      
    def restart_web_server
      system("sudo apache2ctl graceful")
    end
  end
  
end