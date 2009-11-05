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
        :yard      => '0.2.3.5',
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
        "yard --version '0.2.3.5'", 
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
yard --version '0.2.3.5'
bluecloth --version '2.0.5'
      MESSAGE
    end
  end
  
  ##################################################################################################
  
  describe '.warn_at_exit' do
    it "I'm not aware of a technique to test Kernel#at_exit" do
      Plow::Dependencies.should_receive(:at_exit)
      # how to specify that #at_exit receives a block?
      Plow::Dependencies.warn_at_exit
    end
  end
end
