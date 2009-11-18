# encoding: UTF-8
require 'erb'
require 'plow/binding_struct'
require 'plow/strategy/ubuntu_hardy'

class Plow
  # `Plow::Generator` is a **context** class.
  #
  # At run-time, `Plow::Generator` selects an appropiate strategy class.  Each strategy class
  # implements a specific algorithm for web-site template generation.  An instance of 
  # `Plow::Generator` is intended to be passed to the choosen strategy object, as it provides
  # read-only data accessors for user-supplied input as well as convience methods that communicate
  # messages to the user and execute commands on the system.
  #
  # Currently, there is a single strategy implementation.
  #
  # @see Plow::Strategy::UbuntuHardy
  class Generator
    attr_reader :user_name, :site_name, :site_aliases
    attr_reader :strategy
    
    # Instantiates a new `Plow::Generator` object with a user name, site name, and optional
    # site aliases.
    #
    # During instantiation, `Plow::Generator` performs basic data validation on the user-supplied
    # input, raising an exception on any failure.  On success, parameters are cached to instance
    # variables with read-only, public accessors.  Finally, the correct strategy class is selected.
    # This decision is very simple as there is only 1 strategy class at the moment.
    #
    # @example Initialization with two required arguments
    #   generator = Plow::Generator.new('steve', 'www.apple.com')
    #
    # @example Initialization with an optional third argument
    #   generator = Plow::Generator.new('steve', 'www.apple.com', 'apple.com')
    #
    # @return [Plow::Generator] A new instance of `Plow::Generator`
    #
    # @param [String] user_name Name of a Linux system account user (e.g. steve)
    # @param [String] site_name Name of the web-site (e.g. www.apple.com)
    # @param [splat] *site_aliases (Optional) List of alias names of the web-site (e.g. apple.com)
    #
    # @raise [Plow::InvalidSystemUserNameError] Raised when a `user_name` is blank or includes an space character
    # @raise [Plow::InvalidWebSiteNameError] Raised when a `site_name` is blank or includes an space character
    # @raise [Plow::InvalidWebSiteAliasError] Raised when any `site_alias` is blank or includes an space character
    #
    # @see Plow::Strategy::UbuntuHardy
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
      
      @strategy = Plow::Strategy::UbuntuHardy.new(self)
    end
    
    # Executes the pre-choosen strategy.
    #
    # @example Executing a strategy pre-choosen by a `Plow::Generator` instance
    #   generator = Plow::Generator.new('steve', 'www.apple.com')
    #   generator.run!
    #
    # @raise [Plow::NonRootProcessOwnerError] Raised when the process is owned by a non-root user
    def run!
      raise Plow::NonRootProcessOwnerError unless Process.uid == 0
      strategy.execute!
    end
    
    # Renders a message, via the standard output channel, to the user.
    #
    # @example A sample user message
    #   generator.say("Hello World!")
    #
    # @example Sample output
    #   ==> Hello World!
    #
    # @param [String] message A brief message to the user
    def say(message)
      puts "==> #{message}"
    end
    
    # Executes a set of commands in the user's shell enviroment.  Any text rendered out to any
    # channel during execution is **not** captured and simply displayed to the user.  Leading
    # spaces in a command are stripped away and empty lines are ignored.
    #
    # @example Sample usage
    #   generator.shell <<-COMMANDS
    #     
    #     echo "Hello World!"
    #     
    #     cat /etc/passwd
    #   COMMANDS
    #
    # @example Sample shell execution
    #   echo "Hello World!"
    #   cat /etc/passwd
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
    # @example Evaluating a template file with a context and writing the result to back disk
    #   File.open('/path/to/output/file', 'wt') do |file|
    #     generator = Plow::Generator.new('steve', 'www.apple.com')
    #     context   = { :site_name => generator.site_name }
    #     
    #     config = generator.evaluate_template('/path/to/template/file', context)
    #     file.write(config)
    #   end
    #
    # @return [String] The evaluated template data
    # @param [String] template_path A Unix path to a template file
    # @param [Hash] context Key/value pairs, where the key is a template file instance variable, 
    #   and a value is the value to be substituted during evaluation
    def evaluate_template(template_path, context)
      template       = File.read(template_path)
      context_struct = Plow::BindingStruct.new(context)
      ERB.new(template).result(context_struct.get_binding)
    end
  end  
end