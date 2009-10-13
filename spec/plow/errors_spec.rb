# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Custom Application Errors" do
  it "Plow::NonRootProcessOwnerError should be a kind of StandardError" do
    Plow::NonRootProcessOwnerError.new.should be_a_kind_of(StandardError)
  end
  
  it "Plow::InvalidSystemUserNameError should be a kind of StandardError" do
    Plow::InvalidSystemUserNameError.new.should be_a_kind_of(StandardError)
  end
  
  it "Plow::InvalidWebSiteNameError should be a kind of StandardError" do
    Plow::InvalidWebSiteNameError.new.should be_a_kind_of(StandardError)
  end
  
  it "Plow::InvalidWebSiteAliasError should be a kind of StandardError" do
    Plow::InvalidWebSiteAliasError.new.should be_a_kind_of(StandardError)
  end
  
  it "Plow::ReservedSystemUserNameError should be a kind of StandardError" do
    Plow::ReservedSystemUserNameError.new.should be_a_kind_of(StandardError)
  end
  
  it "Plow::SystemUserNameNotFoundError should be a kind of StandardError" do
    Plow::SystemUserNameNotFoundError.new.should be_a_kind_of(StandardError)
  end
  
  it "Plow::AppRootAlreadyExistsError should be a kind of StandardError" do
    Plow::AppRootAlreadyExistsError.new.should be_a_kind_of(StandardError)
  end
  
  it "Plow::ConfigFileAlreadyExistsError should be a kind of StandardError" do
    Plow::ConfigFileAlreadyExistsError.new.should be_a_kind_of(StandardError)
  end
end
