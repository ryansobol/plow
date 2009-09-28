# encoding: UTF-8
require 'plow/generator'

class Plow
  class Application
    class << self
      def launch(*arguments)
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
    3. Generate and install an apache2 VirtualHost configuration

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
        rescue Plow::InvalidSystemUserNameError => invalid
          abort "ERROR: #{invalid} is an invalid system user name"
        rescue Plow::InvalidWebSiteNameError => invalid
          abort "ERROR: #{invalid} is an invalid website name"
        rescue Plow::InvalidWebSiteAliasError => invalid
          abort "ERROR: #{invalid} is an invalid website alias"
        rescue Plow::NonRootProcessOwnerError
          abort "ERROR: This process must be owned or executed by root"
        rescue Plow::ReservedSystemUserNameError => reserved_user_name
          abort "ERROR: #{reserved_user_name} is a reserved system user name"
        rescue Plow::SystemUserNameNotFoundError => not_found
          abort "ERROR: System user name #{not_found} cannot be found when it should exist"
        rescue Plow::AppHomeAlreadyExistsError => already_exists
          abort "ERROR: Application home path #{already_exists} already exists"
        end
        
      end
    end
  end
end