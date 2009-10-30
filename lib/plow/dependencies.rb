# encoding: UTF-8

class Plow
  # In order to load without a syntax error, this file needs to be compatible with ruby >= 1.8.6
  class Dependencies
    REQUIRED_RUBY_VERSION = '1.9.1'
    
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
    
    FILE_NAME_TO_GEM_NAME = {
      :spec => :rspec
    }
    
    @@development_error_messages = []
    
    # Returns a String with the appropriate error message
    #
    # @param error LoadError The error object
    # @return String The developer error message
    def self.warn_for(error)
      error.message.match(/no such file to load -- (\w*)/) do |match_data|
        file_name = match_data[1].to_sym
        gem_name  = (DEVELOPMENT_GEMS.has_key?(file_name) ? file_name : FILE_NAME_TO_GEM_NAME[file_name])
        
        @@development_error_messages << "#{gem_name} --version '#{DEVELOPMENT_GEMS[gem_name]}'"
      end
    end
    
    def self.warn_at_exit(description = 'The following dependencies could not be found:')
      at_exit do
        unless @@development_error_messages.empty?
          message = [description.chomp]
          message += @@development_error_messages
          puts "\n" + message.join("\n")
        end
      end
    end
  end
end
