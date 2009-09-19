# encoding: UTF-8

unless RUBY_VERSION >= '1.9.1'
  abort <<-ERROR
Incompatible ruby version error in #{__FILE__} near line #{__LINE__}
This library requires at least ruby v1.9.1 but you're using ruby v#{RUBY_VERSION}
Please see http://www.ruby-lang.org/
  ERROR
end

require 'plow/application'

class Plow
  VERSION = "0.0.0"
end
