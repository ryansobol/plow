# encoding: UTF-8
require 'plow/generator'

class Plow
  # With a single public method (i.e. `launch`), `Plow::Application` is the main class of and the 
  # point of execution for the library.
  #
  # @see Plow::Application.launch
  class Application
    class << self
      # The starting point of executation for the Plow library.  The procedure for launching the 
      # `Plow::Application` is as follows:
      #
      # 1. Output a version stamp.
      # 2. Ensure at least 2 arguments are provided, aborting with a usage message if not.
      # 3. Parse user provided arguments.
      # 4. Start a new `Plow::Generator` while handling any library specific exceptions raised.
      #
      # @return [Number] Success will return 0, while failure will most likely return a number > 0.
      # @overload launch(user_name, site_name, *site_aliases)
      #   In addition to the user_name and site_aliases, an array of n site_aliases are also 
      #   provided by the user.
      #   @param [String] user_name Name of a Linux system account user (e.g. steve)
      #   @param [String] site_name Name of the web-site (e.g. www.apple.com)
      #   @param [splat] *site_aliases (Optional) List of alias names of the web-site 
      #   (e.g. apple.com)
      def launch(*arguments)
        puts version_stamp
        
        if arguments.length < 2
          abort <<-MESSAGE
Usage: plow USER_NAME SITE_NAME [SITE_ALIAS ...]

  Arguments:
    USER_NAME       Name of a Linux system account user (e.g. steve)
    SITE_NAME       Name of the web-site (e.g. www.apple.com)
    SITE_ALIAS      (Optional) List of alias names of the web-site (e.g. apple.com)

  Summary:
    Plows the fertile soil of your filesystem into neatly organized plots of web-site templates

  Description:
    1. Sharpens it's blade by ensuring that both a Linux system user account and it's home path exist
    2. Penetrates the soil by forming the web-site root path within the user home
    3. Seeds the web-site with an index page and web server log files
    4. Fertilizes the web-site by installing a virtual host configuration into the web server

  Example:
    plow steve www.apple.com apple.com
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
          abort "ERROR: #{invalid} is an invalid web-site name"
        rescue Plow::InvalidWebSiteAliasError => invalid
          abort "ERROR: #{invalid} is an invalid web-site alias"
        rescue Plow::NonRootProcessOwnerError
          abort "ERROR: This process must be owned or executed by root"
        rescue Plow::ReservedSystemUserNameError => reserved
          abort "ERROR: #{reserved} is a reserved system user name"
        rescue Plow::SystemUserNameNotFoundError => not_found
          abort "ERROR: System user name #{not_found} cannot be found when it should exist"
        rescue Plow::AppRootAlreadyExistsError => already_exists
          abort "ERROR: Application root path #{already_exists} already exists"
        rescue Plow::ConfigFileAlreadyExistsError => already_exists
          abort "ERROR: Configuration file #{already_exists} already exists"
        end
      end
      
      private
      
      # Similar to a time stamp, this will return a version stamp of the Plow library containing
      # the version number along with the copyright and license details.
      #
      # @return [String] Version stamp
      # @example Sample version stamp
      #   Plow 1.0.0. Copyright (c) 2009 Ryan Sobol. Licensed under the MIT license.
      def version_stamp
        "Plow #{Plow::VERSION}. Copyright (c) 2009 Ryan Sobol. Licensed under the MIT license."
      end
    end
  end
end