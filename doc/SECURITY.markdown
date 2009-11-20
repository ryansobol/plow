A Brief Note About Security
===========================

Any and all processes invoking this library must be owned, aka executed, by the root user.  Root ownership is required by this package to automate system administrative tasks, including but not limited to:

* Creating and/or modifying operating system user accounts that are _typically controlled by the root user_
* Generating and installing virtual host configuration files for web servers that are _typically owned by the root user_

By installing this package, you are acknowledging the risks inherit of the aforementioned tasks.  If this package, including the library source code and it's non-compiled executables, is owned by any non-root user, then anyone who has or gains access to that non-root account could modify the code in this package, without your knowledge.  The next time you execute the program, as the root user, you could now be unwittingly comprising your own system by running malicious code injected into this package.

If you wish to install this package as a RubyGem with a user account granted root privileges via sudo, then please install this package by running the following command:

    sudo gem install plow

**LET ME BE CRYSTAL CLEAR.  DO NOT INSTALL THIS PACKAGE TO ANY NON-ROOT USER'S GEM REPOSITORY.  YOU'VE BEEN WARNED.**
