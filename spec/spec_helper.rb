# encoding: UTF-8

unless $LOAD_PATH.include?(File.dirname(__FILE__))
  $LOAD_PATH.unshift(File.dirname(__FILE__))
end

unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__) + '/../lib'))
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
end


require 'plow'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end
