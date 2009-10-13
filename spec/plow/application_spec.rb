# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Plow::Application do
  
  ##################################################################################################
  
  describe ".launch when failing" do
    before(:each) do
      @expected_message = <<MESSAGE
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
      $stderr = StringIO.new
    end
    
    after(:each) do
      $stderr = STDERR
    end
    
    it "should abort with usage message with 0 arguments" do
      lambda { Plow::Application.launch }.should raise_error(SystemExit, @expected_message)
    end
    
    it "should abort with usage message with 1 argument" do
      lambda { Plow::Application.launch('marco') }.should raise_error(SystemExit, @expected_message)
    end
  end

  ##################################################################################################

  describe ".launch when passing" do
    it "should start the generator with 2 arguments" do
      argv      = ['apple-steve', 'www.apple.com']
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
      $stderr   = StringIO.new
    end
    
    after(:each) do
      $stderr = STDERR
    end
    
    it "should render error message to the user for raised Plow::InvalidSystemUserNameError" do
      expected_error = Plow::InvalidSystemUserNameError.new(@bad_argv[0])
      Plow::Generator.should_receive(:new).and_raise(expected_error)

      expected_message = "ERROR: #{@bad_argv[0]} is an invalid system user name"
      lambda { Plow::Application.launch(*@bad_argv) }.should raise_error(SystemExit, expected_message)
    end
    
    it "should render error message to the user for raised Plow::InvalidWebSiteNameError" do
      expected_error = Plow::InvalidWebSiteNameError.new(@bad_argv[1])
      Plow::Generator.should_receive(:new).and_raise(expected_error)
      
      expected_message = "ERROR: #{@bad_argv[1]} is an invalid website name"
      lambda { Plow::Application.launch(*@bad_argv) }.should raise_error(SystemExit, expected_message)
    end
    
    it "should render error message to the user for raised Plow::InvalidWebSiteAliasError" do
      expected_error = Plow::InvalidWebSiteAliasError.new(@bad_argv[2])
      Plow::Generator.should_receive(:new).and_raise(expected_error)
      
      expected_message = "ERROR: #{@bad_argv[2]} is an invalid website alias"
      lambda { Plow::Application.launch(*@bad_argv) }.should raise_error(SystemExit, expected_message)
    end
  end
  
  describe "when handing errors from Plow::Generator.run!" do
    before(:each) do
      $stderr   = StringIO.new
      @argv      = ['apple-steve', 'www.apple.com', 'apple.com']
      @generator = mock('generator')
    end
    
    after(:each) do
      $stderr = STDERR
    end
    
    it "should render error message to the user for raised Plow::NonRootProcessOwnerError" do
      expected_error = Plow::NonRootProcessOwnerError
      
      Plow::Generator.should_receive(:new)
        .with(*@argv)
        .and_return(@generator)
      @generator.should_receive(:run!).and_raise(expected_error)
      
      expected_message = "ERROR: This process must be owned or executed by root"
      lambda { Plow::Application.launch(*@argv) }.should raise_error(SystemExit, expected_message)
    end
    
    it "should render error message to the user for raised Plow::ReservedSystemUserNameError" do
      expected_error = Plow::ReservedSystemUserNameError.new(@argv[0])
      
      Plow::Generator.should_receive(:new)
        .with(*@argv)
        .and_return(@generator)
      @generator.should_receive(:run!).and_raise(expected_error)
      
      expected_message = "ERROR: #{@argv[0]} is a reserved system user name"
      lambda { Plow::Application.launch(*@argv) }.should raise_error(SystemExit, expected_message)
    end
    
    it "should render error message to the user for raised Plow::SystemUserNameNotFoundError" do
      expected_error = Plow::SystemUserNameNotFoundError.new(@argv[0])
      
      Plow::Generator.should_receive(:new)
        .with(*@argv)
        .and_return(@generator)
      @generator.should_receive(:run!).and_raise(expected_error)
      
      expected_message = "ERROR: System user name #{@argv[0]} cannot be found when it should exist"
      lambda { Plow::Application.launch(*@argv) }.should raise_error(SystemExit, expected_message)
    end
    
    it "should render error message to the user for raised Plow::AppRootAlreadyExistsError" do
      app_home_path = "/home/#{@argv[0]}/sites/#{@argv[1]}"
      expected_error = Plow::AppRootAlreadyExistsError.new(app_home_path)
      
      Plow::Generator.should_receive(:new)
        .with(*@argv)
        .and_return(@generator)
      @generator.should_receive(:run!).and_raise(expected_error)
      
      expected_message = "ERROR: Application root path #{app_home_path} already exists"
      lambda { Plow::Application.launch(*@argv) }.should raise_error(SystemExit, expected_message)
    end
    
    it "should render error message to the user for raised Plow::AppRootAlreadyExistsError" do
      config_file_path = '/etc/apache2/sites_available/vhost.conf'
      expected_error = Plow::ConfigFileAlreadyExistsError.new(config_file_path)
      
      Plow::Generator.should_receive(:new)
        .with(*@argv)
        .and_return(@generator)
      @generator.should_receive(:run!).and_raise(expected_error)
      
      expected_message = "ERROR: Configuration file #{config_file_path} already exists"
      lambda { Plow::Application.launch(*@argv) }.should raise_error(SystemExit, expected_message)
    end
  end
end
