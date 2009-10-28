require 'rubygems'
require 'rake'

class Plow
  class Dependencies
    RUBY = '= 1.9.1'
    
    DEVELOPMENT = {
      :jeweler   => '= 1.3.0',
      :rspec     => '= 1.2.9',
      :yard      => '= 0.2.3.5',
      :bluecloth => '= 2.0.5'     # hidden yard dependency for markdown support
    }
    
    ##
    # Returns a String with the appropriate error message
    #
    # @param error LoadError The error object
    # @return String The developer error message
    def self.error_message_for(error)
      error.message.match(/no such file to load -- (?<gem_name>\w*)/) do |match_data|
        name = match_data[:gem_name].to_sym
        name = :rspec if name == :spec # thanx for bucking the pattern, rspec! :(
        return "#{name} is not available.  Install it with: gem install #{name} --version '#{DEVELOPMENT[name]}'"
      end
    end
  end
end

###################################################################################################

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    # The gem object is a kind of Gem::Specification 
    # For additional settings, see http://www.rubygems.org/read/chapter/20
    gem.name              = "plow"
    gem.rubyforge_project = "plow" # rubyforge's days are numbered...
    gem.summary           = "Plows the fertile soil of your filesystem into neatly organized plots of web-site templates"
    gem.description       = "Plows the fertile soil of your filesystem into neatly organized plots of web-site templates"
    gem.email             = "code@ryansobol.com"
    gem.homepage          = "http://github.com/ryansobol/plow"
    gem.authors           = ["Ryan Sobol"]
    
    gem.required_ruby_version = Plow::Dependencies::RUBY
    
    Plow::Dependencies::DEVELOPMENT.each_pair do |gem_name, version|
      gem.add_development_dependency(gem_name.to_s, version)
    end
  end
  
  Jeweler::GemcutterTasks.new
  
  Jeweler::RubyforgeTasks.new do |task|
    task.doc_task = false # rubyforge's days are numbered...
  end
rescue LoadError => e
  puts Plow::Dependencies.error_message_for(e)
end

###################################################################################################

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new(:spec)  
  task :default => :spec
rescue LoadError => e
  puts Plow::Dependencies.error_message_for(e)
end

###################################################################################################

begin
  require 'yard'
  require 'bluecloth'
  YARD::Rake::YardocTask.new(:yardoc)
rescue LoadError => e
  puts Plow::Dependencies.error_message_for(e)
end
