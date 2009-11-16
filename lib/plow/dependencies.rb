# encoding: UTF-8

class Plow
  # `Plow::Dependencies` is a class-methods-only **singleton** class that performs both strict
  # parse-time dependency checking and simple, elegant run-time dependency warning.
  #
  # My preferred mental model is to consider software library dependencies as a snapshot in time.
  # I also make the assumption, sometimes incorrectly, that a newer version of a software library
  # is not always a better version.
  #
  # `Plow::Dependencies` automatically enforces a strict parse-time check for the
  # `REQUIRED_RUBY_VERSION` on both application and development processes for the `Plow` library.
  # (i.e. `bin/plow`, `rake`, `spec`, etc)  Because of this, I've ensured this file is
  # syntactically compatible with Ruby 1.8.6 or higher.
  #
  # Currently, `Plow` does **not** enforce strict parse-time version checking on `DEVELOPMENT_GEMS`.
  # In the future, I would like to experiment with using RubyGems and the `Kernel#gem` method to
  # this end.  For now, each developer is responsible for ensuring the correct versions of their
  # necessary development gems are located in the `$LOAD_PATH` on their system.
  #
  # When a gem is required, but a `LoadError` is raised, and rescued, `Plow::Dependencies` can be
  # incorporated into the process to warn a developer of missing development features.  Even with a
  # few methods --  `.create_warning_for` and `.warn_at_exit` --  users are automatically warned, in
  # this case at the moment of termination, about gems that could not found be in the `$LOAD_PATH`.
  #  Using `Plow::Dependencies` is **not** a mandatory inclusion for all gem requirements, merely a
  # guide to help developers quickly see obstacles in their path.
  #
  # @example Simple usage with the Jeweler gem
  #   Plow::Dependencies.warn_at_exit
  #   begin
  #     require 'jeweler'
  #     # work with the Jeweler gem
  #   rescue LoadError => e
  #     Plow::Dependencies.create_warning_for(e)
  #   end
  #
  # @see Plow::Dependencies.create_warning_for
  # @see Plow::Dependencies.warn_at_exit  
  class Dependencies
    # For now, starting with Ruby 1.9.1 but I would like to experiment with compatibility with Ruby >= 1.9.1 in the future.
    REQUIRED_RUBY_VERSION = '1.9.1'
    
    # bluecloth is a hidden yard dependency for markdown support
    DEVELOPMENT_GEMS = {
      :jeweler   => '1.3.0',
      :rspec     => '1.2.9',
      :yard      => '0.4.0',
      :bluecloth => '2.0.5'
    }
    
    # Thanx rspec for bucking the pattern :(
    FILE_NAME_TO_GEM_NAME = {
      :spec => :rspec
    }
    
    # Empties the warnings cache.  This method is called when the class is required.
    def self.destroy_warnings
      @@warnings_cache = []
    end
    destroy_warnings
    
    # Creates and caches a warning from a `LoadError` exception.  Warnings are only created for
    # known development gem dependencies.
    #
    # @param [LoadError] error A rescued exception
    # @raise [RuntimeError] Raised when the `LoadError` argument is an unknown development gem.
    def self.create_warning_for(error)
      error.message.match(/no such file to load -- (\w*)/) do |match_data|
        file_name = match_data[1].to_sym
        gem_name  = if DEVELOPMENT_GEMS.has_key?(file_name)
          file_name
        elsif FILE_NAME_TO_GEM_NAME.has_key?(file_name)
          FILE_NAME_TO_GEM_NAME[file_name]
        else
          raise "Cannot create a dependency warning for unknown development gem -- #{file_name}"
        end
        
        @@warnings_cache << "#{gem_name} --version '#{DEVELOPMENT_GEMS[gem_name]}'"
      end
    end
    
    # Displays a warning message to the user on the standard output channel if there are warnings
    # to render.
    #
    # @example Sample warning message
    #   The following development gem dependencies could not be found. Without them, some available development features are missing:
    #   jeweler --version '1.3.0'
    #   rspec --version '1.2.9'
    #   yard --version '0.4.0'
    #   bluecloth --version '2.0.5'
    def self.render_warnings
      unless @@warnings_cache.empty?
        message = []
        message << "The following development gem dependencies could not be found. Without them, some available development features are missing:"
        message += @@warnings_cache
        puts "\n" + message.join("\n")
      end
    end
    
    # Attaches a call to `render_warnings` to `Kernel#at_exit`
    def self.warn_at_exit
      at_exit { render_warnings }
    end
    
    private
    
    # Checks that the version of the current Ruby process matches the `REQUIRED_RUBY_VERSION`.
    # This method is automatically invoked at the first time this class is required, ensuring the
    # correct Ruby version at parse-time.
    #
    # @param [String] ruby_version Useful for automated specifications.  Defaults to `RUBY_VERSION`.
    # @raise [SystemExit] Raised, with a message, when the process is using an incorrect version of Ruby.
    def self.check_ruby_version(ruby_version = RUBY_VERSION)
      unless ruby_version == REQUIRED_RUBY_VERSION
        abort <<-ERROR
This library requires Ruby #{REQUIRED_RUBY_VERSION}, but you're using #{ruby_version}.
Please visit http://www.ruby-lang.org/ for installation instructions.
        ERROR
      end
    end
    check_ruby_version
  end
end
