![Following the Plow](http://img.skitch.com/20091010-jd9m46i9g5u4fyyprkfe36p4q9.gif)

Image courtesy of [Mother Earth News](http://www.motherearthnews.com/Modern-Homesteading/1974-05-01/Walking-Plow.aspx)

PLOW Release 0.1.0 (October 13th 2009)
======================================

Copyright &copy; 2009 Ryan Sobol. Licensed under the MIT license.  Please see the {file:LICENSE} for more information.

**Homepage**:   [http://github.com/ryansobol/plow](http://github.com/ryansobol/plow)  

WHAT'S NEW?
-----------

**v0.1.0**

* Canonical 'plow' namespace reserved on [Gemcutter](http://gemcutter.org/gems/plow)

I'm currently working at towards assembling a "complete software" package for you.  Please stay tuned for the official launch of version 1.0.0.  :D

Please see {file:HISTORY} for the historical overview of the project.

SYNOPSIS
--------

Plows the fertile soil of your filesystem into neatly organized plots of website templates.

1. Ensure both a system user account and user home exist
2. Lay the foundation of a simple website home
3. Generate and install an apache2 VirtualHost configuration

FEATURES
--------

* RubyGems compatible while also simultaneously completely decoupled

REQUIREMENTS
------------

**Required dependencies**

* Linux Ubuntu 8.04.3 LTS - Hardy Heron
* Ruby 1.9.1

**Optional automated specification dependencies**

* RSpec 1.2.8

**Optional generated API documentation dependencies**

* YARD 0.2.3.5
* BlueCloth 2.0.5

INSTALLING
----------

    sudo gem1.9 install plow

See {file:SECURITY} for details.

USAGE
-----

    Usage: plow USER_NAME SITE_NAME [SITE_ALIAS ...]
    
    Arguments:
      USER_NAME       Name of a Linux system account user
      SITE_NAME       Name of the website (e.g. www.apple.com)
      SITE_ALIAS      (Optional) List of alias names of the website (e.g. apple.com)

EXAMPLES
--------

Running the following command

    $ plow apple-steve www.apple.com apple.com

will produce

    $ tree sites/
    sites/
    |-- README
    `-- example.ryansobol.com
        |-- log
        |   `-- apache2
        |       |-- access.log
        |       `-- error.log
        `-- public
            `-- index.html
    
    4 directories, 4 files
    
    $ ls -hal sites/example.ryansobol.com/log/apache2/
    total 196K
    drwxr-x--- 2 root GROUP 4.0K Sep  5 03:11 .
    drwxr-xr-x 3 USER GROUP 4.0K Sep  5 03:09 ..
    -rw-r----- 1 root GROUP 136K Sep  9 11:10 access.log
    -rw-r----- 1 root GROUP  48K Sep  9 09:06 error.log

MOTIVATION
----------

There exists numerous software products for controlling and/or managing a unix-based operating systems and web servers.  So, why did I decide to write yet another?  With plow, my object is:

**To contribute free, open-source, and complete software for the benefit human-kind**

The terms "free" and "open-source" are common enough to be implicitly understood, or at least, [easily googled](http://www.google.com/searchq=free+open-source).  But what of the term "complete software"?  For me, complete software means four exclusive characteristics:

* Usability enhanced through elegant user-interface combined with straight-forward documentation
* Stability verified through automated test specifications
* Performance demonstrated through benchmarks
* Sustainability preserved through both human and computer readable code

I have tirelessly worked to achieve a high standard in all four characteristics.  As my peer, I am grateful of your input on improving this project in any of these areas.  Please see the sections on REPORTING ISSUES and CONTRIBUTING for further information.

REPORTING ISSUES
----------------

You found a bug or a problem when using plow?  Great!  Please use the [Issue Tracker](http://github.com/ryansobol/plow/issues) to shed light on your issue.  Thank you for taking the time to help improve plow!

CONTRIBUTING
------------

* Fork the project.
* Please take a moment to get a feel of the coding style, documentation, and specifications.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Please see {file:ROAD-MAP} for information on how to most meaningfully contribute to this project.
