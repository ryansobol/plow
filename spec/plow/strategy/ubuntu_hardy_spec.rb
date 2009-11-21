# encoding: UTF-8
require 'spec_helper'

require 'tempfile'

describe Plow::Strategy::UbuntuHardy do
  before(:each) do
    @context  = Plow::Generator.new('steve', 'www.apple.com', 'apple.com')
    @strategy = Plow::Strategy::UbuntuHardy.new(@context)      
    
    @parsed_users_fixture = [ 
      { name: "root",          password: "x", id: 0,      group_id: 0,     info: "root",                               home_path: "/root",              shell_path: "/bin/bash" }, 
      { name: "daemon",        password: "x", id: 1,      group_id: 1,     info: "daemon",                             home_path: "/usr/sbin",          shell_path: "/bin/sh" }, 
      { name: "bin",           password: "x", id: 2,      group_id: 2,     info: "bin",                                home_path: "/bin",               shell_path: "/bin/sh" }, 
      { name: "sys",           password: "x", id: 3,      group_id: 3,     info: "sys",                                home_path: "/dev",               shell_path: "/bin/sh" }, 
      { name: "sync",          password: "x", id: 4,      group_id: 65534, info: "sync",                               home_path: "/bin",               shell_path: "/bin/sync" }, 
      { name: "games",         password: "x", id: 5,      group_id: 60,    info: "games",                              home_path: "/usr/games",         shell_path: "/bin/sh" }, 
      { name: "man",           password: "x", id: 6,      group_id: 12,    info: "man",                                home_path: "/var/cache/man",     shell_path: "/bin/sh" }, 
      { name: "lp",            password: "x", id: 7,      group_id: 7,     info: "lp",                                 home_path: "/var/spool/lpd",     shell_path: "/bin/sh" }, 
      { name: "mail",          password: "x", id: 8,      group_id: 8,     info: "mail",                               home_path: "/var/mail",          shell_path: "/bin/sh" }, 
      { name: "news",          password: "x", id: 9,      group_id: 9,     info: "news",                               home_path: "/var/spool/news",    shell_path: "/bin/sh" }, 
      { name: "uucp",          password: "x", id: 10,     group_id: 10,    info: "uucp",                               home_path: "/var/spool/uucp",    shell_path: "/bin/sh" }, 
      { name: "proxy",         password: "x", id: 13,     group_id: 13,    info: "proxy",                              home_path: "/bin",               shell_path: "/bin/sh" }, 
      { name: "www-data",      password: "x", id: 33,     group_id: 33,    info: "www-data",                           home_path: "/var/www",           shell_path: "/bin/sh" }, 
      { name: "backup",        password: "x", id: 34,     group_id: 34,    info: "backup",                             home_path: "/var/backups",       shell_path: "/bin/sh" }, 
      { name: "list",          password: "x", id: 38,     group_id: 38,    info: "Mailing List Manager",               home_path: "/var/list",          shell_path: "/bin/sh" }, 
      { name: "irc",           password: "x", id: 39,     group_id: 39,    info: "ircd",                               home_path: "/var/run/ircd",      shell_path: "/bin/sh" }, 
      { name: "gnats",         password: "x", id: 41,     group_id: 41,    info: "Gnats Bug-Reporting System (admin)", home_path: "/var/lib/gnats",     shell_path: "/bin/sh" }, 
      { name: "nobody",        password: "x", id: 65534,  group_id: 65534, info: "nobody",                             home_path: "/nonexistent",       shell_path: "/bin/sh" }, 
      { name: "libuuid",       password: "x", id: 100,    group_id: 101,   info: "",                                   home_path: "/var/lib/libuuid",   shell_path: "/bin/sh" }, 
      { name: "dhcp",          password: "x", id: 101,    group_id: 102,   info: "",                                   home_path: "/nonexistent",       shell_path: "/bin/false" }, 
      { name: "syslog",        password: "x", id: 102,    group_id: 103,   info: "",                                   home_path: "/home/syslog",       shell_path: "/bin/false" }, 
      { name: "klog",          password: "x", id: 103,    group_id: 104,   info: "",                                   home_path: "/home/klog",         shell_path: "/bin/false" }, 
      { name: "sshd",          password: "x", id: 104,    group_id: 65534, info: "",                                   home_path: "/var/run/sshd",      shell_path: "/usr/sbin/nologin" }, 
      { name: "Debian-exim",   password: "x", id: 105,    group_id: 109,   info: "",                                   home_path: "/var/spool/exim4",   shell_path: "/bin/false" }, 
      { name: "sadmin",        password: "x", id: 1000,   group_id: 1000,  info: ",,,",                                home_path: "/home/sadmin",       shell_path: "/bin/bash" }, 
      { name: "mysql",         password: "x", id: 106,    group_id: 111,   info: "MySQL Server,,,",                    home_path: "/var/lib/mysql",     shell_path: "/bin/false" }, 
      { name: "steve",         password: "x", id: 1001,   group_id: 1001,  info: ",,,",                                home_path: "/home/steve",        shell_path: "/bin/bash" }
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
    
    it "should set virtual host configuration file name" do
      @strategy.vhost_file_name.should == "www.apple.com.conf"
    end
    
    it "should set virtual host configuration file path" do
      @strategy.vhost_file_path.should == "/etc/apache2/sites-available/www.apple.com.conf"
    end
    
    it "should set virtual host configuration template file path" do
      expected = File.expand_path(File.dirname(__FILE__) + '/../../../lib/plow/strategy/ubuntu_hardy/templates/apache2-vhost.conf')
      @strategy.vhost_template_file_path.should == expected
    end
  end
  
  ##################################################################################################
  
  describe '#say (private)' do
    it 'should proxy to Plow::Generator#say' do
      @context.should_receive(:say).with("something amazing happened!")
      @strategy.send(:say, "something amazing happened!")
    end
  end
  
  ##################################################################################################
  
  describe '#shell (private)' do
    it 'should proxy to Plow::Generator#shell' do
      @context.should_receive(:shell).with("echo *")
      @strategy.send(:shell, "echo *")
    end
  end
  
  ##################################################################################################
  
  describe '#users (private)' do
    it "should read and parse a system accounts file (e.g. /etc/passwd)" do
      @strategy.stub!(:users_file_path).and_return(FIXTURES_PATH + '/passwd.txt')
      @strategy.send(:users) { |user| user.should == @parsed_users_fixture.shift }
    end
  end
  
  ##################################################################################################
  
  describe '#user_exists? (private)' do
    before(:each) do
      @strategy.stub!(:users_file_path).and_return(FIXTURES_PATH + '/passwd.txt')
    end
    
    it "should raise Plow::ReservedSystemUserNameError for a system account where user id < 1000" do
      @context.stub!(:user_name).and_return('sshd')
      lambda { @strategy.send(:user_exists?) }.should raise_error(Plow::ReservedSystemUserNameError, 'sshd')
    end
    
    it "should raise Plow::ReservedSystemUserNameError for a system account where user id == 65534" do
      @context.stub!(:user_name).and_return('nobody')
      lambda { @strategy.send(:user_exists?) }.should raise_error(Plow::ReservedSystemUserNameError, 'nobody')
    end
    
    it "should return false when no matching non-system account is found" do
      @context.stub!(:user_name).and_return('microsoft-steve')
      @strategy.send(:user_exists?).should be_false
    end
    
    it "should return true when a matching non-system account is found" do
      @context.stub!(:user_name).and_return('steve')
      @strategy.send(:user_exists?).should be_true
    end
  end
  
  ##################################################################################################
  
  describe '#create_user! (private)' do
    it "should invoke a adduser as a system call" do
      @strategy.should_receive(:shell).with("adduser steve")
      @strategy.send(:create_user!)
    end
  end
  
  ##################################################################################################
  
  describe '#user_home_exists? (private)' do
    before(:each) do
      @strategy.stub!(:users_file_path).and_return(FIXTURES_PATH + '/passwd.txt')
    end
    
    it "should raise Plow::SystemUserNameNotFoundError if no matching user name is found" do
      @context.stub!(:user_name).and_return('microsoft-steve')
      lambda { @strategy.send(:user_home_exists?) }.should raise_error(Plow::SystemUserNameNotFoundError, 'microsoft-steve')
    end
    
    describe "when home directory exists for existing user" do
      before(:each) do
        @user = @parsed_users_fixture.last
        @context.stub!(:user_name).and_return(@user[:name])
        Dir.should_receive(:exists?).and_return(true)
      end
      
      it "should return true" do
        @strategy.send(:user_home_exists?).should be_true
      end
      
      it "should set user home variable to correct home path" do
        @strategy.send(:user_home_exists?)
        @strategy.user_home_path.should == '/home/steve'
      end
    end
    
    describe "when home directory does not exist for existing user" do
      before(:each) do
        @user = @parsed_users_fixture.last
        @context.stub!(:user_name).and_return(@user[:name])
        Dir.should_receive(:exists?).and_return(false)
      end
      
      it "should return false" do
        @strategy.send(:user_home_exists?).should be_false
      end
      
      it "should set user home variable to correct home path" do
        @strategy.send(:user_home_exists?)
        @strategy.user_home_path.should == '/home/steve'
      end
    end
  end
  
  ##################################################################################################
  
  describe '#create_user_home! (private)' do
    it "should create a user home with the correct ownership" do
      @strategy.stub!(:user_home_path).and_return("/home/steve")
      @strategy.should_receive(:shell).with(<<-COMMANDS)
          mkdir /home/steve
          chown steve:steve /home/steve
      COMMANDS
      @strategy.send(:create_user_home!)
    end
  end
  
  ##################################################################################################
  
  describe '#sites_home_exists? (private)' do
    before(:each) do
      @user = @parsed_users_fixture.last
      @strategy.stub!(:user_home_path).and_return(@user[:home_path])
    end
    
    it "should set sites home variable" do
      @strategy.send(:sites_home_exists?)
      @strategy.sites_home_path.should == "/home/steve/sites"
    end
    
    it "should return true if the directory exists" do
      Dir.should_receive(:exists?).and_return(true)
      @strategy.send(:sites_home_exists?).should be_true
    end
    
    it "should return false if the directory does not exist" do
      Dir.should_receive(:exists?).and_return(false)
      @strategy.send(:sites_home_exists?).should be_false
    end
  end
  
  ##################################################################################################
  
  describe '#create_sites_home! (private)' do
    it "should create a sites home with the correct ownership" do
      @strategy.stub!(:sites_home_path).and_return("/home/steve/sites")
      @strategy.should_receive(:shell).with(<<-COMMANDS)
          mkdir /home/steve/sites
          chown steve:steve /home/steve/sites
      COMMANDS
      @strategy.send(:create_sites_home!)
    end
  end
  
  ##################################################################################################
  
  describe '#app_root_exists? (private)' do
    before(:each) do
      @user = @parsed_users_fixture.last
      @strategy.stub!(:sites_home_path).and_return("#{@user[:home_path]}/sites")
    end
    
    it "should set sites home variable" do
      @strategy.send(:app_root_exists?)
      @strategy.app_root_path.should == "/home/steve/sites/www.apple.com"
    end
    
    it "should return true if the directory exists" do
      Dir.should_receive(:exists?).and_return(true)
      @strategy.send(:app_root_exists?).should be_true
    end
    
    it "should return false if the directory does not exist" do
      Dir.should_receive(:exists?).and_return(false)
      @strategy.send(:app_root_exists?).should be_false
    end
  end
  
  ##################################################################################################
  
  describe '#create_app_root! (private)' do
    it "should create an application home correctly" do
      @strategy.stub!(:app_root_path).and_return('/home/steve/sites/www.apple.com')
      @strategy.should_receive(:shell).with(<<-COMMANDS)
          mkdir /home/steve/sites/www.apple.com
          chown steve:steve /home/steve/sites/www.apple.com
      COMMANDS
      @strategy.send(:create_app_root!)
    end
  end
  
  ##################################################################################################
  
  describe '#create_app_public! (private)' do
    it "should build an application's public files correctly" do
      @strategy.stub!(:app_public_path).and_return('/home/steve/sites/www.apple.com/public')
      @strategy.should_receive(:shell).with(<<-COMMANDS)
          mkdir /home/steve/sites/www.apple.com/public
          touch /home/steve/sites/www.apple.com/public/index.html
          chown -R steve:steve /home/steve/sites/www.apple.com/public
      COMMANDS
      @strategy.send(:create_app_public!)
    end
  end
  
  ##################################################################################################
  
  describe '#create_app_logs! (private)' do
    it "should build an application's log files correctly" do
      @strategy.stub!(:app_log_path).and_return('/home/steve/sites/www.apple.com/log')
      @strategy.should_receive(:shell).with(<<-COMMANDS)
          mkdir /home/steve/sites/www.apple.com/log
          mkdir /home/steve/sites/www.apple.com/log/apache2
          chmod 750 /home/steve/sites/www.apple.com/log/apache2
          
          touch /home/steve/sites/www.apple.com/log/apache2/access.log
          touch /home/steve/sites/www.apple.com/log/apache2/error.log
          
          chmod 640 /home/steve/sites/www.apple.com/log/apache2/*.log
          chown -R steve:steve /home/steve/sites/www.apple.com/log
          chown root -R /home/steve/sites/www.apple.com/log/apache2
      COMMANDS
      @strategy.send(:create_app_logs!)
    end
  end
  
  ##################################################################################################
  
  describe '#vhost_config_exists? (private)' do
    it "should return true if the directory exists" do
      Dir.should_receive(:exists?).and_return(true)
      @strategy.send(:vhost_config_exists?).should be_true
    end
    
    it "should return false if the directory does not exist" do
      Dir.should_receive(:exists?).and_return(false)
      @strategy.send(:vhost_config_exists?).should be_false
    end
  end
  
  ##################################################################################################
  
  describe '#create_vhost_config! (private)' do
    before(:each) do
      @temp_file = Tempfile.new('generate_vhost_config')
      @strategy.stub!(:vhost_file_path).and_return(@temp_file.path)
      @strategy.stub!(:app_public_path).and_return('/home/steve/sites/www.apple.com/public')
      @strategy.stub!(:app_log_path).and_return('/home/steve/sites/www.apple.com/log')
    end
    
    it "should create a vhost config file from template file without site aliases" do
      @context.stub!(:site_aliases).and_return([])
      @strategy.send(:create_vhost_config!)
      
      File.read(@temp_file.path).should == <<-CONFIG

<VirtualHost *:80>
  ServerAdmin webmaster
  ServerName www.apple.com
  
  DirectoryIndex index.html
  DocumentRoot /home/steve/sites/www.apple.com/public
  
  LogLevel warn
  ErrorLog  /home/steve/sites/www.apple.com/log/apache2/error.log
  CustomLog /home/steve/sites/www.apple.com/log/apache2/access.log combined
</VirtualHost>
      CONFIG
    end
    
    it "should create a vhost config file from template file with site aliases" do
      @strategy.send(:create_vhost_config!)
      File.read(@temp_file.path).should == <<-CONFIG

<VirtualHost *:80>
  ServerAdmin webmaster
  ServerName www.apple.com
  
  ServerAlias apple.com
  
  DirectoryIndex index.html
  DocumentRoot /home/steve/sites/www.apple.com/public
  
  LogLevel warn
  ErrorLog  /home/steve/sites/www.apple.com/log/apache2/error.log
  CustomLog /home/steve/sites/www.apple.com/log/apache2/access.log combined
</VirtualHost>
      CONFIG
    end
  end
  
  ##################################################################################################
  
  describe '#install_vhost_config! (private)' do
    it "should enable vhost and restart apache2" do
      @strategy.should_receive(:shell).with(<<-COMMANDS)
          a2ensite www.apple.com.conf > /dev/null
          apache2ctl graceful
      COMMANDS
      @strategy.send(:install_vhost_config!)
    end
  end
  
  ##################################################################################################
  
  describe '#execute!' do
    before(:each) do
      @strategy.stub!(:user_exists?).and_return(false)
      @strategy.stub!(:user_home_exists?).and_return(true)
      @strategy.stub!(:sites_home_exists?).and_return(false)
      @strategy.stub!(:app_root_exists?).and_return(false)
      @strategy.stub!(:vhost_config_exists?).and_return(false)
      
      @strategy.stub!(:user_home_path).and_return('/home/steve')
      @strategy.stub!(:sites_home_path).and_return('/home/steve/sites')
      @strategy.stub!(:app_root_path).and_return('/home/steve/sites/www.apple.com')
      
      $stdout = StringIO.new
    end
    
    after(:each) do
      $stdout = STDOUT
    end
    
    it "should run the default process" do
      @strategy.should_receive(:create_user!)
      @strategy.should_not_receive(:create_user_home!)
      @strategy.should_receive(:create_sites_home!)
      @strategy.should_receive(:create_app_root!)
      @strategy.should_receive(:create_app_public!)
      @strategy.should_receive(:create_app_logs!)
      @strategy.should_receive(:create_vhost_config!)
      @strategy.should_receive(:install_vhost_config!)
      
      @strategy.execute!
      
      @strategy.app_public_path.should == '/home/steve/sites/www.apple.com/public'
      @strategy.app_log_path.should == '/home/steve/sites/www.apple.com/log'
      
      $stdout.string.should == <<-OUTPUT
==> creating steve user
==> existing /home/steve
==> creating /home/steve/sites
==> creating /home/steve/sites/www.apple.com
==> creating /home/steve/sites/www.apple.com/public
==> creating /home/steve/sites/www.apple.com/log
==> creating /etc/apache2/sites-available/www.apple.com.conf
==> installing /etc/apache2/sites-available/www.apple.com.conf
      OUTPUT
    end
    
    it "should run the existing user process" do
      @strategy.stub!(:user_exists?).and_return(true)
      
      @strategy.should_not_receive(:create_user)
      @strategy.should_not_receive(:create_user_home!)
      @strategy.should_receive(:create_sites_home!)
      @strategy.should_receive(:create_app_root!)
      @strategy.should_receive(:create_app_public!)
      @strategy.should_receive(:create_app_logs!)
      @strategy.should_receive(:create_vhost_config!)
      @strategy.should_receive(:install_vhost_config!)
      
      @strategy.execute!
      
      @strategy.app_public_path.should == '/home/steve/sites/www.apple.com/public'
      @strategy.app_log_path.should == '/home/steve/sites/www.apple.com/log'
      
      $stdout.string.should == <<-OUTPUT
==> existing steve user
==> existing /home/steve
==> creating /home/steve/sites
==> creating /home/steve/sites/www.apple.com
==> creating /home/steve/sites/www.apple.com/public
==> creating /home/steve/sites/www.apple.com/log
==> creating /etc/apache2/sites-available/www.apple.com.conf
==> installing /etc/apache2/sites-available/www.apple.com.conf
      OUTPUT
    end
    
    it "should run the missing user home process" do
      @strategy.stub!(:user_home_exists?).and_return(false)
      
      @strategy.should_receive(:create_user!)
      @strategy.should_receive(:create_user_home!)
      @strategy.should_receive(:create_sites_home!)
      @strategy.should_receive(:create_app_root!)
      @strategy.should_receive(:create_app_public!)
      @strategy.should_receive(:create_app_logs!)
      @strategy.should_receive(:create_vhost_config!)
      @strategy.should_receive(:install_vhost_config!)
      
      @strategy.execute!
      
      @strategy.app_public_path.should == '/home/steve/sites/www.apple.com/public'
      @strategy.app_log_path.should == '/home/steve/sites/www.apple.com/log'
      
      $stdout.string.should == <<-OUTPUT
==> creating steve user
==> creating /home/steve
==> creating /home/steve/sites
==> creating /home/steve/sites/www.apple.com
==> creating /home/steve/sites/www.apple.com/public
==> creating /home/steve/sites/www.apple.com/log
==> creating /etc/apache2/sites-available/www.apple.com.conf
==> installing /etc/apache2/sites-available/www.apple.com.conf
      OUTPUT
    end
    
    it "should run the existing sites home process" do
      @strategy.stub!(:sites_home_exists?).and_return(true)
      
      @strategy.should_receive(:create_user!)
      @strategy.should_not_receive(:create_user_home!)
      @strategy.should_not_receive(:create_sites_home!)
      @strategy.should_receive(:create_app_root!)
      @strategy.should_receive(:create_app_public!)
      @strategy.should_receive(:create_app_logs!)
      @strategy.should_receive(:create_vhost_config!)
      @strategy.should_receive(:install_vhost_config!)
      
      @strategy.execute!
      
      @strategy.app_public_path.should == '/home/steve/sites/www.apple.com/public'
      @strategy.app_log_path.should == '/home/steve/sites/www.apple.com/log'
      
      $stdout.string.should == <<-OUTPUT
==> creating steve user
==> existing /home/steve
==> existing /home/steve/sites
==> creating /home/steve/sites/www.apple.com
==> creating /home/steve/sites/www.apple.com/public
==> creating /home/steve/sites/www.apple.com/log
==> creating /etc/apache2/sites-available/www.apple.com.conf
==> installing /etc/apache2/sites-available/www.apple.com.conf
      OUTPUT
    end
    
    it "should run the existing app root process" do
      @strategy.stub!(:app_root_exists?).and_return(true)
      
      @strategy.should_receive(:create_user!)
      @strategy.should_not_receive(:create_user_home!)
      @strategy.should_receive(:create_sites_home!)
      @strategy.should_not_receive(:create_app_root!)
      @strategy.should_not_receive(:create_app_public!)
      @strategy.should_not_receive(:create_app_logs!)
      @strategy.should_not_receive(:create_vhost_config!)
      @strategy.should_not_receive(:install_vhost_config!)
      
      lambda { @strategy.execute! }.should raise_error(Plow::AppRootAlreadyExistsError, '/home/steve/sites/www.apple.com')
      
      $stdout.string.should == <<-OUTPUT
==> creating steve user
==> existing /home/steve
==> creating /home/steve/sites
      OUTPUT
    end
    
    it "should run the existing vhost config process" do
      @strategy.stub!(:vhost_config_exists?).and_return(true)
      
      @strategy.should_receive(:create_user!)
      @strategy.should_not_receive(:create_user_home!)
      @strategy.should_receive(:create_sites_home!)
      @strategy.should_receive(:create_app_root!)
      @strategy.should_receive(:create_app_public!)
      @strategy.should_receive(:create_app_logs!)
      @strategy.should_not_receive(:create_vhost_config!)
      @strategy.should_not_receive(:install_vhost_config!)
      
      lambda { @strategy.execute! }.should raise_error(Plow::ConfigFileAlreadyExistsError, '/etc/apache2/sites-available/www.apple.com.conf')
      
      @strategy.app_public_path.should == '/home/steve/sites/www.apple.com/public'
      @strategy.app_log_path.should == '/home/steve/sites/www.apple.com/log'
      
      $stdout.string.should == <<-OUTPUT
==> creating steve user
==> existing /home/steve
==> creating /home/steve/sites
==> creating /home/steve/sites/www.apple.com
==> creating /home/steve/sites/www.apple.com/public
==> creating /home/steve/sites/www.apple.com/log
      OUTPUT
    end
  end
end
