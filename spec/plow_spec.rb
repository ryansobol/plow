# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Plow" do
  describe " version synchronizing" do
    before(:each) do
      @expected = "0.0.0"
    end
    
    it "should be correct for Plow::VERSION" do
      Plow::VERSION.should == @expected
    end
    
    it "should be correct for the VERSION rubygem file" do
      File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'VERSION'))).should == @expected
    end
  end
end
