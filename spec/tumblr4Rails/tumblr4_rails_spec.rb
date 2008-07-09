require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails do
  include Tumblr4Rails
  
  describe "the module itself" do
    
    it "should respond_to? configuration" do
      Tumblr4Rails.should respond_to(:configuration)
    end
    
    it "should respond_to? configure" do
      Tumblr4Rails.should respond_to(:configure)
    end
    
    it "should raise an exception if configure is called with no block" do
      lambda {
        Tumblr4Rails.configure
      }.should raise_error
    end
    
    it "should have a default configuration without calling configure" do
      config = Tumblr4Rails.configuration
      config.should_not be_nil
      config.email.should be_nil
      config.password.should be_nil
      config.request_type.should == Tumblr4Rails::RequestType.request
    end
    
    it "should raise an exception when request type is request and email is set" do
      lambda {
        Tumblr4Rails.configure do |s|
          s.request_type = Tumblr4Rails::RequestType.request
          s.email = "test@test.ca"
        end
      }.should raise_error
    end
    
    it "should raise an exception when request type is request and password is set" do
      lambda {
        Tumblr4Rails.configure do |s|
          s.request_type = Tumblr4Rails::RequestType.request
          s.password = "**************"
        end
      }.should raise_error
    end
    
    it "should raise an exception when request type is request and log_name is set" do
      lambda {
        Tumblr4Rails.configure do |s|
          s.request_type = Tumblr4Rails::RequestType.request
          s.read_url = "something"
        end
      }.should raise_error
    end
    
    it "should not raise an exception when request type is request" do
      lambda {
        Tumblr4Rails.configure do |s|
          s.request_type = Tumblr4Rails::RequestType.request
        end
      }.should_not raise_error
    end
    
    it "should raise an exception when request type is application and password is not set" do
      lambda {
        Tumblr4Rails.configure do |s|
          s.request_type = Tumblr4Rails::RequestType.application
          s.email "test@test.ca"
          s.read_url "test"
        end
      }.should raise_error
    end
    
    it "should raise an exception when request type is application and email is not set" do
      lambda {
        Tumblr4Rails.configure do |s|
          s.request_type = Tumblr4Rails::RequestType.application
          s.password "********"
          s.read_url "test"
        end
      }.should raise_error
    end
    
    it "should raise an exception when request type is application and read_url is not set" do
      lambda {
        Tumblr4Rails.configure do |s|
          s.request_type = Tumblr4Rails::RequestType.application
          s.password "********"
          s.email "test@test.ca"
        end
      }.should raise_error
    end
    
    it "should not raise an exception when request type is application" do
      lambda {
        Tumblr4Rails.configure do |s|
          s.request_type = Tumblr4Rails::RequestType.application
          s.password "********"
          s.email "test@test.ca"
          s.read_url = "something"
        end
      }.should raise_error
    end
   
    it "should ask the config instance if it is valid" do
      config = Tumblr4Rails::Config.new
      config.should_receive(:valid?).and_return(true)
      Tumblr4Rails.stub!(:configuration).and_return(config)
      Tumblr4Rails.configure {|s| s.request_type = Tumblr4Rails::RequestType.request}
    end
    
    it "should reset the config instance if an exception is thrown after configure" do
      lambda {
        Tumblr4Rails.configure do |s|
          s.request_type = Tumblr4Rails::RequestType.application
        end
      }.should raise_error
      
      Tumblr4Rails.configuration.request_type.should == Tumblr4Rails::RequestType.request
      Tumblr4Rails.configuration.email.should be_nil
      Tumblr4Rails.configuration.password.should be_nil
      Tumblr4Rails.configuration.read_url.should be_nil
    end
    
  end
  
  describe "including the module" do
    
    it "should provide a class method called use_tumblr" do
      self.class.should respond_to(:use_tumblr)
    end
    
  end
  
  describe "after telling it to use_tumblr" do
    
    use_tumblr
    
    it "have Tumblr4Rails included" do
      self.class.included_modules.should be_include(Tumblr4Rails)
    end
    
  end
  
end