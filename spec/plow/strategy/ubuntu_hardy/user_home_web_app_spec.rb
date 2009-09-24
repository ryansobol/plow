# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Plow::Strategy::UbuntuHardy::UserHomeWebApp do
  before(:all) do
    @context  = Plow::Generator.new('apple-steve', 'www.apple.com', 'apple.com')
    @strategy = Plow::Strategy::UbuntuHardy::UserHomeWebApp.new(@context)      
  end
  
  ##################################################################################################
  
  describe "\#new " do  
    it "should set context" do
      @strategy.context.should == @context
    end
    
    it "should set users file name" do
      @strategy.users_file_name.should == '/etc/passwd'
    end
    
    it "should set virtual host configuration file name" do
      @strategy.vhost_file_name.should == "/etc/apache2/sites-available/#{@context.site_name}.conf"
    end
  end
  
  ##################################################################################################
  
  describe "\#say (private) " do
    it "should proxy to Plow::Generator\#say" do
      expected_message = "something amazing happened!"
      @context.should_receive(:say).with(expected_message)
      @strategy.send(:say, expected_message)
    end
  end
  
end
