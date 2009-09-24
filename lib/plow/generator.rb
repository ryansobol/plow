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

require 'plow/strategy/ubuntu_hardy/user_home_web_app'

class Plow
  class Generator
    attr_reader :user_name, :site_name, :site_aliases
    attr_reader :template_pathname
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
      
      @template_pathname = File.dirname(__FILE__) + '/templates'
      
      @strategy = Plow::Strategy::UbuntuHardy::UserHomeWebApp.new(self)
    end
    
    def run!
      raise Plow::NonRootProcessOwnerError unless Process.uid == 0
      strategy.execute
    end
    
    def say(message)
      puts "--> #{message}"
    end
  end
end