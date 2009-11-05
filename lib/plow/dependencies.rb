# encoding: UTF-8

class Plow
  # In order to load without a syntax error, this file needs to be compatible with ruby >= 1.8.6
  # Dependencies are a snapshot in time
  class Dependencies
    # for now, starting with 1.9.1 but would like to ensure compatibility for >= 1.9.1
    REQUIRED_RUBY_VERSION = '1.9.1'
    
    # parse-time guard
    unless RUBY_VERSION >= REQUIRED_RUBY_VERSION
      abort <<-ERROR
This library requires at least Ruby #{REQUIRED_RUBY_VERSION}, but you're using #{RUBY_VERSION}.
Please see http://www.ruby-lang.org/
      ERROR
    end
    
    # bluecloth is a hidden yard dependency for markdown support
    DEVELOPMENT_GEMS = {
      :jeweler   => '1.3.0',
      :rspec     => '1.2.9',
      :yard      => '0.2.3.5',
      :bluecloth => '2.0.5'
    }
    
    # Thanx rspec for bucking the pattern :(
    FILE_NAME_TO_GEM_NAME = {
      :spec => :rspec
    }
    
    @@warnings_cache = []
    
    # Empties the warnings cache
    def self.destroy_warnings
      @@warnings_cache = []
    end
    
    # Creates and caches a warning from a `LoadError` exception.  Warnings are only created for known development gem dependencies.
    #
    # @param error LoadError The error object
    # @raise RuntimeError something
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
    
    # Displays a warning message to the user on the standard output channel
    def self.render_warnings
      unless @@warnings_cache.empty?
        message = []
        message << "The following development gem dependencies could not be found. Without them, some available development features are missing:"
        message += @@warnings_cache
        puts "\n" + message.join("\n")
      end
    end
    
    # Renders a warning message at exit
    def self.warn_at_exit
      at_exit { render_warnings }
    end
  end
end
