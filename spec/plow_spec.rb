# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Plow" do
  describe "should have correct version" do
    before(:all) do
      @expected = "0.0.0"
    end
    
    it "for Plow::VERSION" do
      Plow::VERSION.should == @expected
    end
    
    it "for VERSION rubygem file" do
      File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'VERSION'))).should == @expected
    end
  end
end
