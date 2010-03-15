![Following the Plow](http://img.skitch.com/20091010-jd9m46i9g5u4fyyprkfe36p4q9.gif)

Image courtesy of [Mother Earth News](http://www.motherearthnews.com/Modern-Homesteading/1974-05-01/Walking-Plow.aspx)

Plow release 1.0.1 (March 15, 2009)
===================================

Copyright (c) 2009 Ryan Sobol. Licensed under the MIT license.  Please see the {file:LICENSE} for more information.

**Homepage**: [http://gemcutter.org/gems/plow](http://gemcutter.org/gems/plow)  
**Source Code**: [http://github.com/ryansobol/plow](http://github.com/ryansobol/plow)  
**Documentation**: [http://yardoc.org/docs/ryansobol-plow](http://yardoc.org/docs/ryansobol-plow)  
**Code Metrics**: [http://devver.net/caliper/project?repo=git%3A%2F%2Fgithub.com%2Fryansobol%2Fplow.git](http://devver.net/caliper/project?repo=git%3A%2F%2Fgithub.com%2Fryansobol%2Fplow.git)  
**Bug Tracker**: [http://github.com/ryansobol/plow/issues](http://github.com/ryansobol/plow/issues)  
**Wiki**: [http://wiki.github.com/ryansobol/plow](http://wiki.github.com/ryansobol/plow)  

WHAT'S NEW?
-----------

The optional development dependencies were updated to their latest stable releases.

Please see {file:doc/HISTORY.markdown} for the historical overview of the project.

SYNOPSIS
--------

Plows the fertile soil of your filesystem into neatly organized plots of web-site templates

FEATURES
--------

1. Sharpens it's blade by ensuring that both a Linux system user account and it's home path exist
2. Penetrates the soil by forming the web-site root path within the user home
3. Seeds the web-site with an index page and web server log files
4. Fertilizes the web-site by installing a virtual host configuration into the web server

REQUIREMENTS
------------

**Supported operating system + web server combinations**

* Linux Ubuntu 8.04.3 LTS (Hardy Heron) + Apache 2.2.8

**Required dependencies**

* Ruby 1.9.1

**Optional development dependencies**

* Rake 0.8.7 (bundled with Ruby 1.9.1)
* Jeweler 1.4.0
* RSpec 1.3.0
* YARD 0.5.3
* BlueCloth 2.0.7

INSTALLING
----------

Plow is distributed though the RubyGems ecosystem.  Assuming you've already installed RubyGems, installing Plow is simple:

    sudo gem install plow

**LET ME BE CRYSTAL CLEAR.  DO NOT INSTALL THIS PACKAGE TO ANY NON-ROOT USER'S GEM REPOSITORY.  YOU'VE BEEN WARNED.**

Please see {file:doc/SECURITY.markdown} for a detailed explanation of this advisory.

Note that Plow is RubyGems **compatible** while also simultaneously **decoupled** from it.  Feel free to install Plow manually or use any Ruby package management system of your choice.

USAGE
-----

    Usage: plow USER_NAME SITE_NAME [SITE_ALIAS ...]
    
    Arguments:
      USER_NAME       Name of a Linux system account user (e.g. steve)
      SITE_NAME       Name of the web-site (e.g. www.apple.com)
      SITE_ALIAS      (Optional) List of alias names of the web-site (e.g. apple.com)

Plow is bundled with two executables named `plow` and `plow1.9`.  They are nearly identical, but with the following exception:

* `plow` executes using the shell environment's `ruby` binary.  (e.g. `#!/usr/bin/env ruby`)
* `plow1.9` executes using the shell environment's `ruby1.9` binary.  (e.g. `#!/usr/bin/env ruby1.9`)

**Note:** If your Ruby 1.9 binary is something other than `ruby1.9` (i.e. like `ruby19`) then you'll need to create a shell alias similar to the following:

    alias ruby1.9="`which ruby19`"

EXAMPLE
-------

    $ sudo plow steve www.apple.com apple.com
    Plow 1.0.1. Copyright (c) 2009 Ryan Sobol. Licensed under the MIT license.
    ==> creating steve user
    Adding user `steve' ...
    Adding new group `steve' (1001) ...
    Adding new user `steve' (1001) with group `steve' ...
    Creating home directory `/home/steve' ...
    Copying files from `/etc/skel' ...
    Enter new UNIX password: 
    Retype new UNIX password: 
    passwd: password updated successfully
    Changing the user information for steve
    Enter the new value, or press ENTER for the default
    	Full Name []: 
    	Room Number []: 
    	Work Phone []: 
    	Home Phone []: 
    	Other []: 
    Is the information correct? [y/N] y
    ==> existing /home/steve
    ==> creating /home/steve/sites
    ==> creating /home/steve/sites/www.apple.com
    ==> creating /home/steve/sites/www.apple.com/public
    ==> creating /home/steve/sites/www.apple.com/log
    ==> creating /etc/apache2/sites-available/www.apple.com.conf
    ==> installing /etc/apache2/sites-available/www.apple.com.conf
    
    $ su - steve
    Password: 
    
    $ tree /home/steve/sites/
    /home/steve/sites/
    `-- www.apple.com
        |-- log
        |   `-- apache2
        |       |-- access.log
        |       `-- error.log
        `-- public
            `-- index.html
            
    4 directories, 3 files
    
    $ ls -hal /home/steve/sites/www.apple.com/log/apache2/
    total 8.0K
    drwxr-x--- 2 root  steve 4.0K 2009-11-21 16:33 .
    drwxr-xr-x 3 steve steve 4.0K 2009-11-21 16:33 ..
    -rw-r----- 1 root  steve    0 2009-11-21 16:33 access.log
    -rw-r----- 1 root  steve    0 2009-11-21 16:33 error.log
    
    $ cat /etc/apache2/sites-available/www.apple.com.conf
    
    <VirtualHost *:80>
      ServerAdmin webmaster
      ServerName www.apple.com
      
      ServerAlias apple.com
      
      DirectoryIndex index.html
      DocumentRoot /home/steve/sites/www.apple.com/public
      
      LogLevel warn
      ErrorLog  /home/steve/sites/www.apple.com/log/apache2/error.log
      CustomLog /home/steve/sites/www.apple.com/log/apache2/access.log combined
    </VirtualHost>
    

MOTIVATION
----------

As of the time of writing, there exists countless software products for managing unix-based operating systems and web servers.  So then, why did I decide to write yet another?  For me, Plow was a self-issued challenge **to contribute free, open-source, and complete software for the benefit human-kind**.

The terms "free" and "open-source" software are common enough to be implicitly understood, or at least, [easily googled](http://www.google.com/searchq=free+open-source).  But what of the term "complete software"?  For me, complete software has four exclusive characteristics:

* Usability enhanced through elegant user-interface and straight-forward documentation
* Stability verified through automated test specifications
* Performance demonstrated through benchmarks
* Sustainability preserved through both human and computer readable code

Though never finished, I have worked tirelessly to set a the bar high within each of these characteristics.  As my peer, I am grateful of your input on improving this project.  If you are interested in generously donating your time to Plow, please read the below sections on REPORTING ISSUES and CONTRIBUTING to learn how to best direct your energy.

REPORTING ISSUES
----------------

Is Plow not behaving like you expect it should?  Please forgive me!  Would you take a moment to shed light on my negligence over at the [Issue Tracker](http://github.com/ryansobol/plow/issues)?  Here's a **Pro Tip** -- you can read through existing issues and vote for which issues you'd like to see resolved first!

Thank you for taking the time to help improve Plow.

CONTRIBUTING
------------

Is Plow not behaving like you need?  Open-source to the rescue!  There is a plethora of documentation to bring a Rubyist of any level up to speed.  The API documentation is generated, once the dependencies are met (please see the REQUIREMENTS section), by issuing the follow command:

    $ rake yard

Patches are always welcome and appreciated!  The process is straight-forward for contributing your work back to the source:

* Fork the project -- may I suggest [Github](http://www.github.com)?
* Make your feature addition or bug fix **with specifications**.  It's important that I don't break your hard work in a future version unintentionally.
* Please do not casually alter files in the project root. (e.g. LICENSE, Rakefile, README.markdown, VERSION, etc.)
* Commit your changes and publish the change-set.
* Send me a pull request.  Remember, all specs must pass!

Before making your change, take a moment to get a feel for the style of coding, specifications, and in-line documentation.

Please see {file:doc/ROAD-MAP.markdown} to learn how to flow with the project.  In the near future, I plan on pushing this content directly into the [Issue Tracker](http://github.com/ryansobol/plow/issues).

Again, thank you for taking the time to help improve Plow.
