# encoding: UTF-8
require 'erb'
require 'plow/binding_struct'
require 'plow/strategy/ubuntu_hardy/user_home_web_app'

class Plow
  # `Plow::Generator` is both a **context** and a **controller** class.
  class Generator
    attr_reader :user_name, :site_name, :site_aliases
    attr_reader :strategy
    
    # Creates a new `Generator`
    #
    # @param [String] user_name Name of a Linux system account user (e.g. steve)
    # @param [String] site_name Name of the web-site (e.g. www.apple.com)
    # @param [splat] *site_aliases (Optional) List of alias names of the web-site (e.g. apple.com)
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
    
    # Executes the strategy
    #
    # @raise [Plow::NonRootProcessOwnerError] Raised when the process is owned by a non-root user.
    def run!
      raise Plow::NonRootProcessOwnerError unless Process.uid == 0
      strategy.execute
    end
    
    # Renders a message, via the standard output channel, to the user
    #
    # @param [String] message A brief message to the user
    def say(message)
      puts "==> #{message}"
    end
    
    # Excutes a set of commands in the user's shell enviroment
    #
    # @param [String] commands A set of commands, delimited by line-breaks
    def shell(commands)
      commands.each_line do |command|
        command.strip!
        system(command) unless command.blank?
      end
    end
    
    # Evaluates a template file, located on the user's filesystem, with a context
    #
    # @return [String] The evaluated template data
    # @param [String] template_path A Unix path to a template file
    # @param [Hash] context Key/value pairs, where the key is a template file instance variable, and a value is the value to be substituted during evaluation
    def evaluate_template(template_path, context)
      template       = File.read(template_path)
      context_struct = Plow::BindingStruct.new(context)
      ERB.new(template).result(context_struct.get_binding)
    end
  end  
end