# encoding: UTF-8
require 'lib/plow/dependencies'
Plow::Dependencies.warn_at_exit
  
###################################################################################################

begin
  # TODO experiment with how rubygems activates gems by version requirement in ruby 1.9.1.
  # gem 'jeweler', '1.3.0'
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
    
    gem.required_ruby_version = Plow::Dependencies::REQUIRED_RUBY_VERSION
    
    Plow::Dependencies::DEVELOPMENT_GEMS.each_pair do |name, version|
      gem.add_development_dependency(name.to_s, version)
    end
  end
  
  Jeweler::GemcutterTasks.new
  
  Jeweler::RubyforgeTasks.new do |task|
    task.doc_task = false # rubyforge's days are numbered...
  end
rescue LoadError => e
  Plow::Dependencies.create_warning_for(e)
end

###################################################################################################

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new(:spec)  
  task :default => :spec
rescue LoadError => e
  Plow::Dependencies.create_warning_for(e)
end

###################################################################################################

begin
  require 'yard'
  require 'bluecloth' # hidden yard dependency for markdown support
  YARD::Rake::YardocTask.new(:yardoc)
rescue LoadError => e
  Plow::Dependencies.create_warning_for(e)
end
