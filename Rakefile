require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "plow"
    gem.summary     = "Plows the fertile soil of your filesystem into neatly organized plots of website templates"
    gem.description = "Plows the fertile soil of your filesystem into neatly organized plots of website templates"
    gem.email       = "code@ryansobol.com"
    gem.homepage    = "http://github.com/ryansobol/plow"
    gem.authors     = ["Ryan Sobol"]
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "yard"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options = ['--markup', 'markdown', '-', 'LICENSE', 'HISTORY', 'SECURITY']
    t.after = lambda { `cp -R docs/images/ doc/images/` }
  end
rescue LoadError => e
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
