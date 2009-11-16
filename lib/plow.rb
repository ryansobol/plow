# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'plow/dependencies' # ruby version guard
require 'plow/core_ext/object'
require 'plow/errors'
require 'plow/application'

# Library namespace
class Plow
  # Current stable deployed version
  VERSION = "0.1.0"
end
