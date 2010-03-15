# encoding: UTF-8
require 'spec_helper'

describe "Plow" do
  describe "version synchronizing" do
    before(:each) do
      @expected = "1.0.1"
    end
    
    it "should be correct for Plow::VERSION" do
      Plow::VERSION.should == @expected
    end
    
    it "should be correct for the VERSION rubygem file" do
      actual = File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'VERSION'))).chomp
      actual.should == @expected
    end
  end
end
