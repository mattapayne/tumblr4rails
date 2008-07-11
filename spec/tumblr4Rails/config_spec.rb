require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::Config do
  
  def set_properties(*props)
    return if props.blank?
    props.flatten.each do |p|
      @conf.send("#{p}=".to_sym, "Something")
    end
  end
    
  before(:each) do
    @conf = Tumblr4Rails::Config.new
  end
  
  it "should default to a request_type of :request" do
    @conf.request_type.should == Tumblr4Rails::RequestType.request
  end
  
  it "should default to a password of nil" do
    @conf.password.should be_nil
  end
  
  it "should default to an email of nil" do
    @conf.email.should be_nil
  end
  
  it "should default to a read url of nil" do
    @conf.read_url.should be_nil
  end
  
  it "should default to a write url (constant defined in class)" do
    @conf.write_url.should == Tumblr4Rails::Config::DEFAULT_WRITE_URL
  end
  
  it "should have an empty hash for mime types" do
    @conf.upload_mime_types.should_not be_nil
    @conf.upload_mime_types.should be_is_a(Hash)
  end
  
  describe "valid?" do
    
    it "should call validate_for_request when request_type is :request" do
      @conf.should_receive(:validate).with(Tumblr4Rails::RequestType.request, true)
      @conf.valid?
    end
    
    it "should call validate_for_request when request_type is :application" do
      @conf.request_type = Tumblr4Rails::RequestType.application
      @conf.should_receive(:validate).with(Tumblr4Rails::RequestType.application, false)
      @conf.valid?
    end
    
  end
  
  describe "errors when request_type is :application" do
    
    before(:each) do
      @conf.request_type = Tumblr4Rails::RequestType.application
    end
    
    it "should have 3 errors when no other properties are set" do
      @conf.errors.should have(3).item
    end
    
    it "should have 0 errors if all required properties are set" do
      set_properties(:email, :password, :read_url)
      @conf.errors.should be_empty
    end
    
    it "should have 1 error if email is not set" do
      set_properties(:password, :read_url)
      @conf.errors.should have(1).item
    end
    
    it "should have 1 error if password is not set" do
      set_properties(:email, :read_url)
      @conf.errors.should have(1).item
    end
    
    it "should have 1 error if read_url is not set" do
      set_properties(:email, :password)
      @conf.errors.should have(1).item
    end
    
    it "should have 1 error if write_url is set to blank" do
      set_properties(:email, :password, :read_url)
      @conf.write_url = nil
      @conf.errors.should have(1).items
    end
  end
  
  describe "errors when request_type is :request" do
    
    it "should have 0 errors when no other properties are set" do
      @conf.errors.should be_empty
    end
    
    it "should have 1 error when email is set" do
      set_properties(:email)
      @conf.errors.should have(1).item
    end
    
    it "should have 1 error when password is set" do
      set_properties(:password)
      @conf.errors.should have(1).item
    end
    
    it "should have 1 error when read_url is set" do
      set_properties(:read_url)
      @conf.errors.should have(1).items
    end
    
    it "should have 2 errors when email and password are set" do
      set_properties(:email, :password)
      @conf.errors.should have(2).items
    end
   
  end
  
end