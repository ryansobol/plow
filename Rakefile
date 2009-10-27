require 'rubygems'
require 'rake'

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
    gem.add_development_dependency "rspec", "= 1.2.8"
    gem.add_development_dependency "yard", "= 0.2.3.5"
    gem.add_development_dependency "bluecloth", "= 2.0.5"  # hidden yard dependency for markdown support
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
  
  Jeweler::RubyforgeTasks.new do |task|
    task.doc_task = "yardoc"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |task|
  task.libs << 'lib' << 'spec'
  task.spec_files = FileList['spec/**/*_spec.rb']
  task.spec_opts  = %w{ -O spec/spec.opts }
end

Spec::Rake::SpecTask.new(:rcov) do |task|
  task.libs << 'lib' << 'spec'
  task.pattern = 'spec/**/*_spec.rb'
  task.rcov    = true
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError => e
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
