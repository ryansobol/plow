# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Plow::Strategy::UbuntuHardy::UserHomeWebApp do
  describe "\#new " do
    before(:all) do
      @expected_context = Plow::Generator.new('apple-steve', 'www.apple.com', 'apple.com')
      @strategy = Plow::Strategy::UbuntuHardy::UserHomeWebApp.new(@expected_context)      
    end
    
    it "should set context" do
      @strategy.context.should == @expected_context
    end
    
    it "should set users file name" do
      @strategy.users_file_name.should == '/etc/passwd'
    end
    
    it "should set virtual host configuration file name" do
      @strategy.vhost_file_name.should == "/etc/apache2/sites-available/#{@expected_context.site_name}.conf"
    end
  end
end
