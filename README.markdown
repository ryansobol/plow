![Following the Plow](http://img.skitch.com/20091010-jd9m46i9g5u4fyyprkfe36p4q9.gif)

Image courtesy of [Mother Earth News](http://www.motherearthnews.com/Modern-Homesteading/1974-05-01/Walking-Plow.aspx)

PLOW Release 0.1.0 (October 13th 2009)
======================================

Copyright &copy; 2009 Ryan Sobol. Licensed under the MIT license.  Please see the {file:LICENSE} for more information.

**Homepage**:       [http://github.com/ryansobol/plow](http://github.com/ryansobol/plow)  

**Documentation**:  [http://yardoc.org/docs/ryansobol-plow](http://yardoc.org/docs/ryansobol-plow)  
**Code Metrics**: [http://devver.net/caliper/project?repo=git%3A%2F%2Fgithub.com%2Fryansobol%2Fplow.git](http://devver.net/caliper/project?repo=git%3A%2F%2Fgithub.com%2Fryansobol%2Fplow.git)  

WHAT'S NEW?
-----------

**v0.1.0**

* Canonical 'plow' namespace reserved on [Gemcutter](http://gemcutter.org/gems/plow) and [Rubyforge](http://rubyforge.org/projects/plow/)

I'm currently working at towards assembling a "complete software" package for you.  Please stay tuned for the official launch of version 1.0.0.  :D

Please see {file:doc/HISTORY} for the historical overview of the project.

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
* Jeweler 1.3.0
* RSpec 1.2.9
* YARD 0.2.3.5
* BlueCloth 2.0.5

INSTALLING
----------

Plow is distributed though the RubyGems ecosystem.  Assuming you've already installed RubyGems, installing Plow is simple:

    sudo gem install plow

LET ME BE CRYSTAL CLEAR.  DO NOT INSTALL THIS PACKAGE TO ANY NON-ROOT USER'S GEM REPOSITORY.  YOU'VE BEEN WARNED.  Please see {file:doc/SECURITY} for a detailed explanation of this advisory.

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

    $ plow steve www.apple.com apple.com
    
    ... plow interation ...
    
    $ tree /home/steve/sites/
    /home/steve/sites/
    |-- README
    `-- www.apple.com
        |-- log
        |   `-- apache2
        |       |-- access.log
        |       `-- error.log
        `-- public
            `-- index.html
    
    4 directories, 4 files
    
    $ ls -hal /home/steve/sites/www.apple.com/log/apache2/
    total 196K
    drwxr-x--- 2 root  steve 4.0K Sep  5 03:11 .
    drwxr-xr-x 3 steve steve 4.0K Sep  5 03:09 ..
    -rw-r----- 1 root  steve 136K Sep  9 11:10 access.log
    -rw-r----- 1 root  steve  48K Sep  9 09:06 error.log

MOTIVATION
----------

There exists numerous software products for controlling and/or managing a unix-based operating systems and web servers.  So, why did I decide to write yet another?  With Plow, I needed to prove to myself that I have the necessary proficiency **to contribute free, open-source, and complete software for the benefit human-kind**.

The terms "free" and "open-source" are common enough to be implicitly understood, or at least, [easily googled](http://www.google.com/searchq=free+open-source).  But what of the term "complete software"?  For me, complete software means four exclusive characteristics:

* Usability enhanced through elegant user-interface combined with straight-forward documentation
* Stability verified through automated test specifications
* Performance demonstrated through benchmarks
* Sustainability preserved through both human and computer readable code

I have tirelessly worked to achieve a high standard in all four characteristics.  As my peer, I am grateful of your input on improving this project in any of these areas.  Please see the sections on REPORTING ISSUES and CONTRIBUTING for further information.

REPORTING ISSUES
----------------

Is Plow not behaving like you expect it should?  Please forgive me!  Would you take a moment to shed light on my negligence over at the [Issue Tracker](http://github.com/ryansobol/plow/issues)?  

Thank you, in advance, for taking the time to help improve Plow.

CONTRIBUTING
------------

Is Plow not behaving like you need?  Open-source to the rescue!  There is a plethora of documentation to bring you up to speed.  The API documentation is generated, once the dependencies are met (please see the REQUIREMENTS section), by running the follow:

    $ rake yardoc

Patches are always welcome and appreciated!  To contribute your work back to the source, the process is straight-forward:

* Fork the project -- may I suggest [Github](http://www.github.com)?
* Make your feature addition or bug fix with specifications -- it's important that I don't break your hard work in a future version unintentionally.
* Please do not casually alter files in the project root. (e.g. LICENSE, Rakefile, README.markdown, VERSION, etc.)
* Commit your changes and publish the change-set.
* Send me a pull request.  All specs must pass!

Take a moment to get a feel for the style of coding, specifications, and in-line documentation.  I apologize in advance for setting the standards so high.  Please see {file:doc/ROAD-MAP} to learn how to flow with the project.
