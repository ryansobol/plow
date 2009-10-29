# encoding: UTF-8

class Plow
  ##
  # In order to load without a syntax error, this file needs to be compatible with ruby >= 1.8.6
  class Dependencies
    REQUIRED_RUBY_VERSION = '1.9.1'
    
    unless RUBY_VERSION >= REQUIRED_RUBY_VERSION
      abort <<-ERROR
    Incompatible ruby version error in #{__FILE__} near line #{__LINE__}
    This library requires at least ruby #{REQUIRED_RUBY_VERSION} but you're using ruby v#{RUBY_VERSION}
    Please see http://www.ruby-lang.org/
      ERROR
    end
    
    DEVELOPMENT_GEMS = {
      :jeweler   => '1.3.0',
      :rspec     => '1.2.9',
      :yard      => '0.2.3.5',
      :bluecloth => '2.0.5'     # hidden yard dependency for markdown support
    }
    
    FILE_NAME_TO_GEM_NAME = {
      :spec => :rspec
    }
    
    @@development_error_messages = []
    
    ##
    # Returns a String with the appropriate error message
    #
    # @param error LoadError The error object
    # @return String The developer error message
    def self.generate_development_error_message_for(error)
      error.message.match(/no such file to load -- (\w*)/) do |match_data|
        file_name = match_data[1].to_sym
        gem_name  = (DEVELOPMENT.has_key?(file_name) ? file_name : FILE_NAME_TO_GEM_NAME[file_name])
        
        @@development_error_messages << "#{gem_name} --version '#{DEVELOPMENT_GEMS[gem_name]}'"
      end
    end
    
    def self.display_development_error_message
      return if @@development_error_messages.empty?
      message = ["\nThe following gems could not be found. Without them, some available Rake tasks are missing:"]
      message += @@development_error_messages
      puts message.join("\n")
    end
    
    def self.warn_about_development_dependency_errors_at_exit
      at_exit { display_development_error_message }
    end
  end
end
