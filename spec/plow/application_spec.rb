# encoding: UTF-8
require 'spec_helper'

describe Plow::Application do
  
  before(:each) do
    @expected_version_stamp = "Plow 1.0.1. Copyright (c) 2009 Ryan Sobol. Licensed under the MIT license."
  end
  
  ##################################################################################################
  
  describe ".version_stamp" do
    it "should create a version stamp as a String" do
      Plow::Application.send(:version_stamp).should == @expected_version_stamp
    end
  end
  
  ##################################################################################################
  
  describe ".launch when failing" do
    before(:each) do
      @expected_message = <<MESSAGE
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
      $stdout = StringIO.new
      $stderr = StringIO.new
    end
    
    after(:each) do
      $stdout = STDOUT
      $stderr = STDERR
    end
    
    it "should output the version stamp" do
      lambda { Plow::Application.launch }.should raise_exception
      $stdout.string.should == @expected_version_stamp + "\n"
    end
    
    it "should abort with usage message with 0 arguments" do
      lambda { Plow::Application.launch }.should raise_exception(SystemExit, @expected_message)
    end
    
    it "should abort with usage message with 1 argument" do
      lambda { Plow::Application.launch('marco') }.should raise_exception(SystemExit, @expected_message)
    end
  end

  ##################################################################################################

  describe ".launch when passing" do
    before(:each) do
      $stdout = StringIO.new
    end
    
    after(:each) do
      $stdout = STDOUT
    end
    
    it "should output the version stamp" do
      argv      = ['steve', 'www.apple.com']
      generator = mock('generator')
      
      Plow::Generator.should_receive(:new)
        .with(*argv)
        .and_return(generator)
      generator.should_receive(:run!)
      
      Plow::Application.launch(*argv)
      
      $stdout.string.should == @expected_version_stamp + "\n"
    end
    
    it "should start the generator with 2 arguments" do
      argv      = ['steve', 'www.apple.com']
      generator = mock('generator')
      
      Plow::Generator.should_receive(:new)
        .with(*argv)
        .and_return(generator)
      generator.should_receive(:run!)
      
      Plow::Application.launch(*argv).should == 0
    end
    
    it "should start the generator with 3 arguments" do
      argv      = ['marco-polo', 'www.marcopolo.com', 'marcopolo.com']
      generator = mock('generator')
      
      Plow::Generator.should_receive(:new)
        .with(*argv)
        .and_return(generator)
      generator.should_receive(:run!)
      
      Plow::Application.launch(*argv).should == 0
    end
    
    it "should start the generator with 4 arguments" do
      argv      = ['marco-polo', 'www.marcopolo.com', 'marcopolo.com', 'asia.marcopolo.com']
      generator = mock('generator')
      
      Plow::Generator.should_receive(:new)
        .with(*argv)
        .and_return(generator)
      generator.should_receive(:run!)
      
      Plow::Application.launch(*argv).should == 0
    end
  end

  ##################################################################################################
  
  describe "when handling errors from Plow::Generator.new" do
    before(:each) do
      @bad_argv = ['bad user name', 'bad site name', 'bad site alias']
      $stdout   = StringIO.new
      $stderr   = StringIO.new
    end
    
    after(:each) do
      $stdout = STDOUT
      $stderr = STDERR
    end
    
    it "should render error message to the user for raised Plow::InvalidSystemUserNameError" do
      expected_error = Plow::InvalidSystemUserNameError.new(@bad_argv[0])
      Plow::Generator.should_receive(:new).and_raise(expected_error)

      expected_message = "ERROR: #{@bad_argv[0]} is an invalid system user name"
      lambda { Plow::Application.launch(*@bad_argv) }.should raise_exception(SystemExit, expected_message)
    end
    
    it "should render error message to the user for raised Plow::InvalidWebSiteNameError" do
      expected_error = Plow::InvalidWebSiteNameError.new(@bad_argv[1])
      Plow::Generator.should_receive(:new).and_raise(expected_error)
      
      expected_message = "ERROR: #{@bad_argv[1]} is an invalid web-site name"
      lambda { Plow::Application.launch(*@bad_argv) }.should raise_exception(SystemExit, expected_message)
    end
    
    it "should render error message to the user for raised Plow::InvalidWebSiteAliasError" do
      expected_error = Plow::InvalidWebSiteAliasError.new(@bad_argv[2])
      Plow::Generator.should_receive(:new).and_raise(expected_error)
      
      expected_message = "ERROR: #{@bad_argv[2]} is an invalid web-site alias"
      lambda { Plow::Application.launch(*@bad_argv) }.should raise_exception(SystemExit, expected_message)
    end
  end
  
  describe "when handing errors from Plow::Generator.run!" do
    before(:each) do
      $stdout    = StringIO.new
      $stderr    = StringIO.new
      @argv      = ['steve', 'www.apple.com', 'apple.com']
      @generator = mock('generator')
    end
    
    after(:each) do
      $stdout = STDOUT
      $stderr = STDERR
    end
    
    it "should render error message to the user for raised Plow::NonRootProcessOwnerError" do
      expected_error = Plow::NonRootProcessOwnerError
      
      Plow::Generator.should_receive(:new)
        .with(*@argv)
        .and_return(@generator)
      @generator.should_receive(:run!).and_raise(expected_error)
      
      expected_message = "ERROR: This process must be owned or executed by root"
      lambda { Plow::Application.launch(*@argv) }.should raise_exception(SystemExit, expected_message)
    end
    
    it "should render error message to the user for raised Plow::ReservedSystemUserNameError" do
      expected_error = Plow::ReservedSystemUserNameError.new(@argv[0])
      
      Plow::Generator.should_receive(:new)
        .with(*@argv)
        .and_return(@generator)
      @generator.should_receive(:run!).and_raise(expected_error)
      
      expected_message = "ERROR: #{@argv[0]} is a reserved system user name"
      lambda { Plow::Application.launch(*@argv) }.should raise_exception(SystemExit, expected_message)
    end
    
    it "should render error message to the user for raised Plow::SystemUserNameNotFoundError" do
      expected_error = Plow::SystemUserNameNotFoundError.new(@argv[0])
      
      Plow::Generator.should_receive(:new)
        .with(*@argv)
        .and_return(@generator)
      @generator.should_receive(:run!).and_raise(expected_error)
      
      expected_message = "ERROR: System user name #{@argv[0]} cannot be found when it should exist"
      lambda { Plow::Application.launch(*@argv) }.should raise_exception(SystemExit, expected_message)
    end
    
    it "should render error message to the user for raised Plow::AppRootAlreadyExistsError" do
      app_home_path = "/home/#{@argv[0]}/sites/#{@argv[1]}"
      expected_error = Plow::AppRootAlreadyExistsError.new(app_home_path)
      
      Plow::Generator.should_receive(:new)
        .with(*@argv)
        .and_return(@generator)
      @generator.should_receive(:run!).and_raise(expected_error)
      
      expected_message = "ERROR: Application root path #{app_home_path} already exists"
      lambda { Plow::Application.launch(*@argv) }.should raise_exception(SystemExit, expected_message)
    end
    
    it "should render error message to the user for raised Plow::AppRootAlreadyExistsError" do
      config_file_path = '/etc/apache2/sites_available/vhost.conf'
      expected_error = Plow::ConfigFileAlreadyExistsError.new(config_file_path)
      
      Plow::Generator.should_receive(:new)
        .with(*@argv)
        .and_return(@generator)
      @generator.should_receive(:run!).and_raise(expected_error)
      
      expected_message = "ERROR: Configuration file #{config_file_path} already exists"
      lambda { Plow::Application.launch(*@argv) }.should raise_exception(SystemExit, expected_message)
    end
  end
end
