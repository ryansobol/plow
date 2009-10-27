require 'rubygems'
require 'rake'

###################################################################################################

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name              = "plow"
    gem.rubyforge_project = "plow"
    gem.summary           = "Plows the fertile soil of your filesystem into neatly organized plots of web-site templates"
    gem.description       = "Plows the fertile soil of your filesystem into neatly organized plots of web-site templates"
    gem.email             = "code@ryansobol.com"
    gem.homepage          = "http://github.com/ryansobol/plow"
    gem.authors           = ["Ryan Sobol"]
    gem.add_development_dependency "rspec", "= 1.2.9"
    gem.add_development_dependency "yard", "= 0.2.3.5"
    gem.add_development_dependency "bluecloth", "= 2.0.5"  # hidden yard dependency for markdown support
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  
  Jeweler::GemcutterTasks.new
  
  Jeweler::RubyforgeTasks.new do |task|
    task.doc_task = false # rubyforge's days are numbered...
  end
  
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

###################################################################################################

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new(:spec)
  
  Spec::Rake::SpecTask.new(:rcov) do |task|
    task.rcov = true # creates a 'clobber_rcov' task as well
  end
rescue LoadError
  # error message handled by Jeweler's dependency checker
end

###################################################################################################

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:yardoc)
rescue LoadError
  # error message handled by Jeweler's dependency checker
end

###################################################################################################

task :default => :spec

# perform a library dependency check (via Jeweler) before the following tasks
[:spec, :rcov, :clobber_rcov, :yardoc].each do |name|
  task name => :check_dependencies
end
