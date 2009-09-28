# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Plow::Generator do
  
  ##################################################################################################
  
  describe ".new when failing" do
    it "should raise Plow::InvalidSystemUserNameError if first argument is blank" do
      lambda { Plow::Generator.new(nil, 'not-blank') }.should raise_error(Plow::InvalidSystemUserNameError, nil)
    end
    
    it "should raise Plow::InvalidSystemUserNameError if first argument contains a blank space" do
      lambda { Plow::Generator.new('oh noes!', 'not-blank') }.should raise_error(Plow::InvalidSystemUserNameError, 'oh noes!')
    end
    
    it "should raise Plow::InvalidWebSiteNameError if second argument is blank" do
      lambda { Plow::Generator.new('not-blank', nil) }.should raise_error(Plow::InvalidWebSiteNameError, nil)
    end
    
    it "should raise Plow::InvalidWebSiteNameError if second argument contains a blank space" do
      lambda { Plow::Generator.new('not-blank', 'oh noes!') }.should raise_error(Plow::InvalidWebSiteNameError, 'oh noes!')
    end
    
    it "should raise Plow::InvalidWebSiteAliasError if third argument is blank" do
      lambda { Plow::Generator.new('not-blank', 'not-blank', nil) }.should raise_error(Plow::InvalidWebSiteAliasError, nil)
    end
    
    it "should raise Plow::InvalidWebSiteAliasError if third argument contains a blank space" do
      lambda { Plow::Generator.new('not-blank', 'not-blank', 'oh noes!') }.should raise_error(Plow::InvalidWebSiteAliasError, 'oh noes!')
    end
  end
  
  ##################################################################################################
  
  describe ".new when passing with two good arguments" do
    before(:each) do
      @generator = Plow::Generator.new('apple-steve', 'www.apple.com')
    end
    
    it "should set user_name" do
      @generator.user_name.should == 'apple-steve'
    end
    
    it "should set site_name" do
      @generator.site_name.should == 'www.apple.com'
    end
    
    it "should set site_aliases to an empty Array" do
      @generator.site_aliases.should == []
    end
    
    it "should set strategy to an instance of Plow::Strategy::UbuntuHardy::UserHomeWebApp" do
      @generator.strategy.should be_an_instance_of(Plow::Strategy::UbuntuHardy::UserHomeWebApp)
    end
  end
  
  ##################################################################################################
  
  describe ".new when passing with three good arguments" do
    before(:each) do
      @generator = Plow::Generator.new('apple-steve', 'www.apple.com', 'apple.com')
    end
    
    it "should set user_name" do
      @generator.user_name.should == 'apple-steve'
    end
    
    it "should set site_name" do
      @generator.site_name.should == 'www.apple.com'
    end
    
    it "should set site_aliases to an single element Array" do
      @generator.site_aliases.should == ['apple.com']
    end
    
    it "should set strategy to an instance of Plow::Strategy::UbuntuHardy::UserHomeWebApp" do
      @generator.strategy.should be_an_instance_of(Plow::Strategy::UbuntuHardy::UserHomeWebApp)
    end
  end
  
  ##################################################################################################
  
  describe ".run!" do
    it "should raise Plow::NonRootProcessOwnerError when process is owned by non-root user" do
      Process.stub!(:uid).and_return(1)
      generator = Plow::Generator.new('apple-steve', 'www.apple.com', 'apple.com')
      lambda { generator.run! }.should raise_error(Plow::NonRootProcessOwnerError)
    end
    
    it "should execute the strategy when process is owned by root user" do
      Process.stub!(:uid).and_return(0)
      generator = Plow::Generator.new('apple-steve', 'www.apple.com', 'apple.com')
      generator.strategy.should_receive(:execute)
      generator.run!
    end
  end
  
  ##################################################################################################
  
  describe '#say' do
    before(:each) do
      $stdout    = StringIO.new
      @generator = Plow::Generator.new('apple-steve', 'www.apple.com', 'apple.com')
    end
    
    after(:each) do
      $stdout = STDOUT
    end
    
    it "should output message to the user" do
      message = "Something great happened!"
      @generator.say(message)
      $stdout.string.should == "--> #{message}\n"
    end
  end
  
  ##################################################################################################
  
  describe '#evaluate_template' do
    it "should accept a template path and a context Hash and evaluate them together" do
      template_path   = FIXTURES_PATH + '/vhost.conf'
      context_hash    = { site_name: 'www.apple.com' }
      expected_output = <<-OUTPUT
<VirtualHost *:80>
  ServerName www.apple.com
</VirtualHost>
      OUTPUT
      
      generator = Plow::Generator.new('apple-steve', 'www.apple.com', 'apple.com')
      generator.evaluate_template(template_path, context_hash).should == expected_output
    end
  end
end
