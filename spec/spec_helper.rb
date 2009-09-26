# encoding: UTF-8

unless $LOAD_PATH.include?(File.dirname(__FILE__))
  $LOAD_PATH.unshift(File.dirname(__FILE__))
end

unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__) + '/../lib'))
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
end

begin
  require 'spec'
  require 'spec/autorun'
rescue LoadError
  abort <<-ERROR
Unexpected LoadError exception caught in #{__FILE__} on #{__LINE__}

This file depends on the rspec library, which is not available.
You may install the library via rubygems with: sudo gem install rspec
  ERROR
end

require 'plow'

FIXTURES_PATH = File.dirname(__FILE__) + '/fixtures'

Spec::Runner.configure do |config|
  
end
