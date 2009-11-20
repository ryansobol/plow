History of Plow
===============

1.0.0 released on November ??th 2009
------------------------------------

  * bin/plow and bin/plow1.9
    * two ruby 1.9.1 compatible command-line executables.
    * combined with Plow::Application, the entire application logic is decoupled from the plow generator library.
  * lib/plow.rb
    * adds the lib/ directory to the head of the load path if necessary
    * specifies the load order for critical, library-wide classes
    * maintains the library version in memory
  * lib/plow/application.rb
    * decoupled argument parsing from the generator
    * displays usage for the command-line executables
    * handles run-time errors gracefully for the user
    * starts the generator
    * Combined with the executables, the entire application logic is decoupled from the plow generator library.
  * lib/plow/binding_struct.rb
    * adapter class that converts a Hash object into instances variables, which then is used as the binding object for ERB
  * lib/plow/core_ext/object.rb
    * expands the base `Object` class with sensible methods
  * lib/plow/dependencies.rb
    * provides parse-time and run-time dependency checking and warning
  * lib/plow/errors.rb
    * defines a handful of run-time error classes
  * lib/plow/generator.rb
    * maintains the shared state data including a strategy object
    * passes execution to the strategy object
    * provides shared logic for outputting messages to the user
    * provides shared logic for executing shell commands
    * provides shared logic for evaluating ERB template files
  * lib/plow/strategy/ubuntu_hardy.rb
    * userhome-based strategy for generating a system-wide web-site structure for the Linux Ubuntu Hardy 8.04.3 LTS operating system
    * understanding and managing the security implications of web server of virtual hosts
  * lib/plow/strategy/ubuntu_hardy/templates/apache2-vhost.conf
    * a simple apache2 virtual host ERB template file for the Linux Ubuntu Hardy 8.04.3 LTS operating system
  * Rakefile
    * incorporating deployments with jeweler and gemcutter and rubyforge

0.1.0 released on October 13th 2009
-----------------------------------

  * Canonical 'plow' namespace reserved on Gemcutter and Rubyforge
