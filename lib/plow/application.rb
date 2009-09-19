# encoding: UTF-8

require 'plow/generator'

class Plow
  class Application
    class << self
      def run!(*arguments)
        ## parse arguments
        
        begin
          generator = Plow::Generator.new(user_name, site_name, site_aliases)
          generator.run
          return 0
        rescue Exception => e
          ## handle each custom Plow exception in isolation
          puts e
          return 1
        end
        
      end
    end
  end
end