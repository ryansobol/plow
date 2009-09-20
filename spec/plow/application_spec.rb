# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Plow::Application do
  
  ##################################################################################################
  
  describe "should abort with usage message when run!" do
    before(:each) do
      @expected_message = <<-MESSAGE
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
      $stderr = StringIO.new
    end
    
    after(:each) do
      $stderr = STDERR
    end
    
    it "with 0 arguments" do
      lambda { Plow::Application.run! }.should raise_error(SystemExit, @expected_message)
    end
    
    it "with 1 argument" do
      lambda { Plow::Application.run!('marco') }.should raise_error(SystemExit, @expected_message)
    end
  end

  ##################################################################################################

  describe "should start the generator when run!" do
    it "with 2 arguments" do
      generator = mock('generator')
      Plow::Generator.should_receive(:new)
        .with('marco-polo', 'www.marcopolo.com', [])
        .and_return(generator)
      generator.should_receive(:run!)
      
      argv = ['marco-polo', 'www.marcopolo.com']
      Plow::Application.run!(*argv)
    end
    
    it "with 3 arguments" do
      generator = mock('generator')
      Plow::Generator.should_receive(:new)
        .with('marco-polo', 'www.marcopolo.com', ['marcopolo.com'])
        .and_return(generator)
      generator.should_receive(:run!)
      
      argv = ['marco-polo', 'www.marcopolo.com', 'marcopolo.com']
      Plow::Application.run!(*argv)
    end
    
    it "with 4 arguments" do
      generator = mock('generator')
      Plow::Generator.should_receive(:new)
        .with('marco-polo', 'www.marcopolo.com', ['marcopolo.com', 'asia.marcopolo.com'])
        .and_return(generator)
      generator.should_receive(:run!)
      
      argv = ['marco-polo', 'www.marcopolo.com', 'marcopolo.com', 'asia.marcopolo.com']
      Plow::Application.run!(*argv)
    end
  end

end
