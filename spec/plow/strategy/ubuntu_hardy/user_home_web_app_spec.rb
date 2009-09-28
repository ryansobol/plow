# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Plow::Strategy::UbuntuHardy::UserHomeWebApp do
  before(:each) do
    @context  = Plow::Generator.new('apple-steve', 'www.apple.com', 'apple.com')
    @strategy = Plow::Strategy::UbuntuHardy::UserHomeWebApp.new(@context)      
    
    @parsed_passwd_fixture = [ 
      { user_name: "root",          password: "x", user_id: 0,      group_id: 0,     user_info: "root",                               home_path: "/root",              shell_path: "/bin/bash" }, 
      { user_name: "daemon",        password: "x", user_id: 1,      group_id: 1,     user_info: "daemon",                             home_path: "/usr/sbin",          shell_path: "/bin/sh" }, 
      { user_name: "bin",           password: "x", user_id: 2,      group_id: 2,     user_info: "bin",                                home_path: "/bin",               shell_path: "/bin/sh" }, 
      { user_name: "sys",           password: "x", user_id: 3,      group_id: 3,     user_info: "sys",                                home_path: "/dev",               shell_path: "/bin/sh" }, 
      { user_name: "sync",          password: "x", user_id: 4,      group_id: 65534, user_info: "sync",                               home_path: "/bin",               shell_path: "/bin/sync" }, 
      { user_name: "games",         password: "x", user_id: 5,      group_id: 60,    user_info: "games",                              home_path: "/usr/games",         shell_path: "/bin/sh" }, 
      { user_name: "man",           password: "x", user_id: 6,      group_id: 12,    user_info: "man",                                home_path: "/var/cache/man",     shell_path: "/bin/sh" }, 
      { user_name: "lp",            password: "x", user_id: 7,      group_id: 7,     user_info: "lp",                                 home_path: "/var/spool/lpd",     shell_path: "/bin/sh" }, 
      { user_name: "mail",          password: "x", user_id: 8,      group_id: 8,     user_info: "mail",                               home_path: "/var/mail",          shell_path: "/bin/sh" }, 
      { user_name: "news",          password: "x", user_id: 9,      group_id: 9,     user_info: "news",                               home_path: "/var/spool/news",    shell_path: "/bin/sh" }, 
      { user_name: "uucp",          password: "x", user_id: 10,     group_id: 10,    user_info: "uucp",                               home_path: "/var/spool/uucp",    shell_path: "/bin/sh" }, 
      { user_name: "proxy",         password: "x", user_id: 13,     group_id: 13,    user_info: "proxy",                              home_path: "/bin",               shell_path: "/bin/sh" }, 
      { user_name: "www-data",      password: "x", user_id: 33,     group_id: 33,    user_info: "www-data",                           home_path: "/var/www",           shell_path: "/bin/sh" }, 
      { user_name: "backup",        password: "x", user_id: 34,     group_id: 34,    user_info: "backup",                             home_path: "/var/backups",       shell_path: "/bin/sh" }, 
      { user_name: "list",          password: "x", user_id: 38,     group_id: 38,    user_info: "Mailing List Manager",               home_path: "/var/list",          shell_path: "/bin/sh" }, 
      { user_name: "irc",           password: "x", user_id: 39,     group_id: 39,    user_info: "ircd",                               home_path: "/var/run/ircd",      shell_path: "/bin/sh" }, 
      { user_name: "gnats",         password: "x", user_id: 41,     group_id: 41,    user_info: "Gnats Bug-Reporting System (admin)", home_path: "/var/lib/gnats",     shell_path: "/bin/sh" }, 
      { user_name: "nobody",        password: "x", user_id: 65534,  group_id: 65534, user_info: "nobody",                             home_path: "/nonexistent",       shell_path: "/bin/sh" }, 
      { user_name: "libuuid",       password: "x", user_id: 100,    group_id: 101,   user_info: "",                                   home_path: "/var/lib/libuuid",   shell_path: "/bin/sh" }, 
      { user_name: "dhcp",          password: "x", user_id: 101,    group_id: 102,   user_info: "",                                   home_path: "/nonexistent",       shell_path: "/bin/false" }, 
      { user_name: "syslog",        password: "x", user_id: 102,    group_id: 103,   user_info: "",                                   home_path: "/home/syslog",       shell_path: "/bin/false" }, 
      { user_name: "klog",          password: "x", user_id: 103,    group_id: 104,   user_info: "",                                   home_path: "/home/klog",         shell_path: "/bin/false" }, 
      { user_name: "sshd",          password: "x", user_id: 104,    group_id: 65534, user_info: "",                                   home_path: "/var/run/sshd",      shell_path: "/usr/sbin/nologin" }, 
      { user_name: "Debian-exim",   password: "x", user_id: 105,    group_id: 109,   user_info: "",                                   home_path: "/var/spool/exim4",   shell_path: "/bin/false" }, 
      { user_name: "sadmin",        password: "x", user_id: 1000,   group_id: 1000,  user_info: ",,,",                                home_path: "/home/sadmin",       shell_path: "/bin/bash" }, 
      { user_name: "mysql",         password: "x", user_id: 106,    group_id: 111,   user_info: "MySQL Server,,,",                    home_path: "/var/lib/mysql",     shell_path: "/bin/false" }, 
      { user_name: "apple-steve",   password: "x", user_id: 1001,   group_id: 1001,  user_info: ",,,",                                home_path: "/home/apple-steve",  shell_path: "/bin/bash" }
    ]
    
  end
  
  ##################################################################################################
  
  describe ".new" do  
    it "should set context" do
      @strategy.context.should == @context
    end
    
    it "should set users file path" do
      @strategy.users_file_path.should == '/etc/passwd'
    end
    
    it "should set virtual host configuration file path" do
      @strategy.vhost_file_path.should == "/etc/apache2/sites-available/#{@context.site_name}.conf"
    end
  end
  
  ##################################################################################################
  
  describe "\#say (private)" do
    it "should proxy to Plow::Generator\#say" do
      expected_message = "something amazing happened!"
      @context.should_receive(:say).with(expected_message)
      @strategy.send(:say, expected_message)
    end
  end
  
  ##################################################################################################
  
  describe "\#system_accounts (private)" do
    it "should read and parse a system accounts file (e.g. /etc/passwd)" do
      @strategy.stub!(:users_file_path).and_return(FIXTURES_PATH + '/passwd.txt')
      
      @strategy.send(:system_accounts) do |system_account|
        system_account.should == @parsed_passwd_fixture.shift
      end
    end
  end
  
  ##################################################################################################
  
  describe "\#system_account_exists? (private)" do
    before(:each) do
      @strategy.stub!(:users_file_path).and_return(FIXTURES_PATH + '/passwd.txt')
    end
    
    it "should raise Plow::ReservedSystemUserNameError for a system account where user id < 1000" do
      @context.stub!(:user_name).and_return('sshd')
      lambda { @strategy.send(:system_account_exists?) }.should raise_error(Plow::ReservedSystemUserNameError, @context.user_name)
    end
    
    it "should raise Plow::ReservedSystemUserNameError for a system account where user id == 65534" do
      @context.stub!(:user_name).and_return('nobody')
      lambda { @strategy.send(:system_account_exists?) }.should raise_error(Plow::ReservedSystemUserNameError)
    end
    
    it "should return false when no matching non-system account is found" do
      @context.stub!(:user_name).and_return('microsoft-steve')
      @strategy.send(:system_account_exists?).should be_false
    end
    
    it "should return true when a matching non-system account is found" do
      @context.stub!(:user_name).and_return('apple-steve')
      @strategy.send(:system_account_exists?).should be_true
    end
  end
  
  ##################################################################################################
  
  describe "\#create_system_account (private)" do
    it "should invoke a adduser as a system call" do
      @strategy.should_receive(:system).with("adduser #{@context.user_name}")
      @strategy.send(:create_system_account)
    end
  end
  
  ##################################################################################################
  
  describe "\#system_account_home_exists? (private)" do
    before(:each) do
      @strategy.stub!(:users_file_path).and_return(FIXTURES_PATH + '/passwd.txt')
    end
    
    it "should raise Plow::SystemUserNameNotFoundError if no matching user name is found" do
      @context.stub!(:user_name).and_return('microsoft-steve')
      lambda { @strategy.send(:system_account_home_exists?) }.should raise_error(Plow::SystemUserNameNotFoundError)
    end
    
    describe "when home directory exists for existing user" do
      before(:each) do
        @account = @parsed_passwd_fixture.last
        @context.stub!(:user_name).and_return(@account[:user_name])
        Dir.should_receive(:exists?).and_return(true)
      end
      
      it "should return true" do
        @strategy.send(:system_account_home_exists?).should be_true
      end
      
      it "should set user home variable to correct home path" do
        @strategy.send(:system_account_home_exists?)
        @strategy.user_home.should == @account[:home_path]
      end
    end
    
    describe "when home directory does not exist for existing user" do
      before(:each) do
        @account = @parsed_passwd_fixture.last
        @context.stub!(:user_name).and_return(@account[:user_name])
        Dir.should_receive(:exists?).and_return(false)
      end
      
      it "should return false" do
        @strategy.send(:system_account_home_exists?).should be_false
      end
      
      it "should set user home variable to correct home path" do
        @strategy.send(:system_account_home_exists?)
        @strategy.user_home.should == @account[:home_path]
      end
    end
  end
  
  ##################################################################################################
  
  describe "\#create_system_account_home (private)" do
    it "should create a user home with the correct ownership" do
      @strategy.stub!(:user_home).and_return("/home/apple-steve")
      @strategy.should_receive(:system)
        .with("mkdir #{@strategy.user_home}")
        .ordered
      @strategy.should_receive(:system)
        .with("chown #{@context.user_name}:#{@context.user_name} #{@strategy.user_home}")
        .ordered
      @strategy.send(:create_system_account_home)
    end
  end
  
  ##################################################################################################
  
  describe "\#system_account_sites_home_exists? (private)" do
    before(:each) do
      @account = @parsed_passwd_fixture.last
      @strategy.stub!(:user_home).and_return(@account[:home_path])
    end
    
    it "should set sites home variable" do
      @strategy.send(:system_account_sites_home_exists?)
      @strategy.sites_home.should == "#{@account[:home_path]}/sites"
    end
    
    it "should return true if the directory exists" do
      Dir.should_receive(:exists?).and_return(true)
      @strategy.send(:system_account_sites_home_exists?).should be_true
    end
    
    it "should return false if the directory does not exist" do
      Dir.should_receive(:exists?).and_return(false)
      @strategy.send(:system_account_sites_home_exists?).should be_false
    end
  end
  
  ##################################################################################################
  
  describe "\#create_system_account_sites_home (private)" do
    it "should create a sites home with the correct ownership" do
      @strategy.stub!(:user_home).and_return("/home/apple-steve/sites")
      @strategy.should_receive(:system)
        .with("mkdir #{@strategy.sites_home}")
        .ordered
      @strategy.should_receive(:system)
        .with("chown #{@context.user_name}:#{@context.user_name} #{@strategy.sites_home}")
        .ordered
      @strategy.send(:create_system_account_sites_home)
    end
  end
end
