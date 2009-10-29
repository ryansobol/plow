# encoding: UTF-8
require 'erb'

require 'plow/binding_struct'
require 'plow/strategy/ubuntu_hardy/user_home_web_app'

class Plow
  class Generator
    attr_reader :user_name, :site_name, :site_aliases
    attr_reader :strategy
    
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
      
      @user_name    = user_name
      @site_name    = site_name
      @site_aliases = site_aliases
      
      @strategy = Plow::Strategy::UbuntuHardy::UserHomeWebApp.new(self)
    end
    
    def run!
      raise Plow::NonRootProcessOwnerError unless Process.uid == 0
      strategy.execute
    end
    
    def say(message)
      puts "==> #{message}"
    end
    
    def shell(commands)
      commands.each_line do |command|
        command.strip!
        system(command) unless command.blank?
      end
    end
    
    def evaluate_template(template_path, context)
      template = File.read(template_path)
      context_struct = Plow::BindingStruct.new(context)
      ERB.new(template).result(context_struct.get_binding)
    end
  end  
end