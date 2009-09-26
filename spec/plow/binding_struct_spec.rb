# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Plow::BindingStruct do
  
  before(:each) do
    @arguments = { first_name: 'Carl', last_name: 'Sagan' }
    @struct    = Plow::BindingStruct.new(@arguments)
  end
  
  ##################################################################################################
  
  describe ".new" do
    it "should create instance variables for all keys of a parameter Hash" do
      @struct.instance_variables.sort.should == @arguments.keys.sort.map { |key| "@#{key}".to_sym }
    end
    
    it "should initialze all instance variables with the values of a parameter Hash" do
      @struct.instance_variables.each do |ivar|
        @struct.instance_variable_get(ivar).should == @arguments[ivar.to_s.gsub("@", '').to_sym]
      end
    end
  end
  
  ##################################################################################################
  
  describe "\#get_binding" do
    it "should return a Binding object of the instance" do
      ivars = @arguments.keys.sort.map { |key| "@#{key}".to_sym }
      ivars.each do |ivar|
        actual = eval(ivar.to_s, @struct.get_binding)
        actual.should == @arguments[ivar.to_s.gsub("@", '').to_sym]
        actual.should == @struct.instance_variable_get(ivar)
      end
    end
  end
end