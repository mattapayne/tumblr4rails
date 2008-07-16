require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::WriteOptions::QueryHandler do
  
   def handler(options)
    Tumblr4Rails::WriteOptions::QueryHandler.new(options)
  end
  
  def create_options(other={})
    {:email => "test@test.ca", :password => "xxxx", 
      :action => :authenticate, 
      :write_url => "http://www.test.ca/write"}.merge(other)
  end
  
  def create_options_except(*args)
    args = args.flatten
    create_options.reject {|k,v| args.include?(k)}
  end
  
  describe "validate_values!" do
    
    it "should raise an exception if the specified action is not in the set of accepted actions" do
      options = create_options(:action => :blah)
      lambda {handler(options).process!}.should raise_error
    end
    
    it "should raise an exception if the specified action is blank" do
      options = create_options(:action => nil)
      lambda {handler(options).process!}.should raise_error
    end
    
    it "should raise an exception if the write url is invalid" do
      options = create_options(:write_url => "fdfsf")
      lambda {handler(options).process!}.should raise_error
    end
    
    it "should raise an exception if the write url is blank" do
      options = create_options(:write_url => nil)
      lambda {handler(options).process!}.should raise_error
    end
    
    it "should not raise an exception if all arguments are good" do
      lambda {handler(create_options).process!}.should_not raise_error
    end
    
  end
  
  describe "ensure_required!" do
    
    it "should raise an exception if a required param is missing" do
      options = create_options_except(:email)
      lambda {handler(options).process!}.should raise_error
    end
    
    it "should not raise an exception if all required params are present" do
      lambda {handler(create_options).process!}.should_not raise_error
    end
    
  end
  
  describe "cleanse!" do
    
    it "should remove any params that are not in the accepted set" do
      options = create_options(:xxx => "dfsd")
      options.should be_key(:xxx)
      result = handler(options).process!
      result.should_not be_key(:xxx)
    end
    
    it "should remove any entries that have blank values" do
      options = create_options(:email => "")
      h = handler(options)
      h.stub!(:ensure_required!)
      result = h.process!
      result.should_not be_key(:email)
    end
    
    it "should remove any entries that have nil values" do
      options = create_options(:email => nil)
      h = handler(options)
      h.stub!(:ensure_required!)
      result = h.process!
      result.should_not be_key(:email)
    end
    
  end
  
  describe "process!" do
    
    it "should call cleanse!" do
      h = handler(create_options)
      h.should_receive(:cleanse!)
      h.process!
    end
    
    it "should call ensure_required!" do
      h = handler(create_options)
      h.should_receive(:ensure_required!)
      h.process!
    end
    
    it "should call validate_values!" do
      h = handler(create_options)
      h.should_receive(:validate_values!)
      h.process!
    end
    
  end
  
end