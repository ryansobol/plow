# encoding: UTF-8
require 'plow/generator'

class Plow
  class Application
    class << self
      def run!(*arguments)
        if arguments.length < 2
          abort <<-MESSAGE
Usage: plow USER_NAME SITE_NAME [SITE_ALIAS ...]

  Arguments:
    USER_NAME       Name of a Linux system account user
    SITE_NAME       Name of the website (e.g. www.apple.com)
    SITE_ALIAS      (Optional) List of alias names of the website (e.g. apple.com)

  Summary:
    Plows the fertile soil of your filesystem into neatly organized plots of website templates

  Description:
    1. Ensure both a system user account and user home exist
    2. Lay the foundation of a simple website home
    3. Generate and install a VirtualHost apache2 configuration

  Example:
    plow apple-steve www.apple.com apple.com
MESSAGE
        end

        user_name, site_name = arguments.first(2)
        site_aliases         = arguments.drop(2)
        
        begin
          generator = Plow::Generator.new(user_name, site_name, *site_aliases)
          generator.run!
          return 0
        rescue Plow::NonRootProcessOwnerError
          $stderr.puts "ERROR: Invoking Plow::Generator.run! requires a root process owner!"
          return 1
        rescue Plow::InvalidSystemUserNameError
          $stderr.puts "ERROR: #{user_name} is an invalid system user name"
          return 1
        rescue Plow::InvalidWebSiteNameError
          $stderr.puts "ERROR: #{site_name} is an invalid website name"
          return 1
        rescue Plow::InvalidWebSiteAliasError
          $stderr.puts "ERROR: #{site_aliases} is an invalid website alias"
          return 1
        end
        
      end
    end
  end
end