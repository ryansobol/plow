# encoding: UTF-8
require 'spec_helper'

describe Plow::Dependencies do
  
  ##################################################################################################
  
  describe "class constant and variable defaults" do
    it "required ruby version should be correct" do
      Plow::Dependencies::REQUIRED_RUBY_VERSION.should == '1.9.1'
    end

    it "development gem names and versions should be correct" do
      expected = {
        :jeweler   => '1.3.0',
        :rspec     => '1.2.9',
        :yard      => '0.4.0',
        :bluecloth => '2.0.5'
      }

      Plow::Dependencies::DEVELOPMENT_GEMS.should == expected
    end

    it "file name to gem name look-up table should be correct" do
      expected = {
        :spec => :rspec
      }
      Plow::Dependencies::FILE_NAME_TO_GEM_NAME.should == expected
    end
    
    it "warnings cache should be empty" do
      Plow::Dependencies.class_variable_get(:@@warnings_cache).should be_empty
    end
  end
  
  ##################################################################################################
  
  describe '.check_ruby_version (private)' do
    before(:each) do
      $stderr = StringIO.new
    end
    
    after(:each) do
      $stderr = STDERR
    end
    
    def expected_message(version)
      @expected_message = <<-ERROR
This library requires Ruby 1.9.1, but you're using #{version}.
Please visit http://www.ruby-lang.org/ for installation instructions.
      ERROR
    end
    
    it "should abort for ruby 1.8.6" do
      version = '1.8.6'
      lambda { Plow::Dependencies.send(:check_ruby_version, version) }.should raise_error(SystemExit, expected_message(version))
    end
    
    it "should abort for ruby 1.8.7" do
      version = '1.8.7'
      lambda { Plow::Dependencies.send(:check_ruby_version, version) }.should raise_error(SystemExit, expected_message(version))
    end
    
    it "should abort for ruby 1.9.0" do
      version = '1.9.0'
      lambda { Plow::Dependencies.send(:check_ruby_version, version) }.should raise_error(SystemExit, expected_message(version))
    end
    
    it "should not abort for ruby 1.9.1" do
      version = '1.9.1'
      lambda { Plow::Dependencies.send(:check_ruby_version, version) }.should_not raise_error(SystemExit, expected_message(version))
    end
    
    it "should abort for ruby 1.9.2" do
      version = '1.9.2'
      lambda { Plow::Dependencies.send(:check_ruby_version, version) }.should raise_error(SystemExit, expected_message(version))
    end
  end
  
  ##################################################################################################
  
  describe '.destroy_warnings' do
    it "should empty the warnings cache" do
      Plow::Dependencies.class_variable_get(:@@warnings_cache).should be_empty
      
      Plow::Dependencies.create_warning_for(LoadError.new("no such file to load -- jeweler"))
      Plow::Dependencies.class_variable_get(:@@warnings_cache).should_not be_empty
      
      Plow::Dependencies.destroy_warnings
      Plow::Dependencies.class_variable_get(:@@warnings_cache).should be_empty
    end
  end
  
  ##################################################################################################
  
  describe '.create_warning_for' do
    after(:each) do
      Plow::Dependencies.destroy_warnings
    end
    
    it "should create and cache one warning from a known development gem dependency" do
      Plow::Dependencies.create_warning_for(LoadError.new("no such file to load -- jeweler"))
      Plow::Dependencies.class_variable_get(:@@warnings_cache).should ==  ["jeweler --version '1.3.0'"]
    end
    
    it "should create and cache warnings from all known development gem dependencies" do
      Plow::Dependencies::DEVELOPMENT_GEMS.each_key do |file_name|
        gem_name = if Plow::Dependencies::FILE_NAME_TO_GEM_NAME.has_key?(file_name)
          Plow::Dependencies::FILE_NAME_TO_GEM_NAME[file_name]
        else
          file_name
        end
        load_error = LoadError.new("no such file to load -- #{gem_name}")
        Plow::Dependencies.create_warning_for(load_error)
      end

      expected = [
        "jeweler --version '1.3.0'", 
        "rspec --version '1.2.9'", 
        "yard --version '0.4.0'", 
        "bluecloth --version '2.0.5'"
      ]
      Plow::Dependencies.class_variable_get(:@@warnings_cache).should == expected
    end
    
    it "should raise an exception when creating a warning from an unknown development gem dependency" do
      lambda { Plow::Dependencies.create_warning_for(LoadError.new("no such file to load -- _fakegem")) }.should raise_error(RuntimeError, "Cannot create a dependency warning for unknown development gem -- _fakegem")
    end
  end
  
  ##################################################################################################
  
  describe '.render_warnings' do
    before(:each) do
      $stdout = StringIO.new
    end
    
    after(:each) do
      $stdout = STDOUT
    end
    
    it "should display a warning message to the user on the standard output channel" do  
      Plow::Dependencies.create_warning_for(LoadError.new("no such file to load -- jeweler"))
      Plow::Dependencies.create_warning_for(LoadError.new("no such file to load -- spec"))
      Plow::Dependencies.create_warning_for(LoadError.new("no such file to load -- yard"))
      Plow::Dependencies.create_warning_for(LoadError.new("no such file to load -- bluecloth"))
      Plow::Dependencies.render_warnings
      $stdout.string.should == <<-MESSAGE

The following development gem dependencies could not be found. Without them, some available development features are missing:
jeweler --version '1.3.0'
rspec --version '1.2.9'
yard --version '0.4.0'
bluecloth --version '2.0.5'
      MESSAGE
    end
    
    it "should not display a warning message to the user if there are no warnings in the cache" do
      Plow::Dependencies.destroy_warnings
      Plow::Dependencies.render_warnings
      $stdout.string.should == ''
    end
  end
  
  ##################################################################################################
  
  describe '.warn_at_exit' do
    it 'should ensure Kernel#at_exit is invoked with a block' do
      Plow::Dependencies.should_receive(:at_exit)
      # TODO how to specify that #at_exit receives a block?
      # maybe i can intercept the block, execute it and test the output?
      Plow::Dependencies.warn_at_exit
    end
  end
end
