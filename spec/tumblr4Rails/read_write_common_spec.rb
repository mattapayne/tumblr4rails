require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::ReadWriteCommon do
  include Tumblr4Rails::ReadWriteCommon
  
  describe "method_missing" do
    
    it "should be able to handle a missing method that ends with _provided?" do
      self.monkey_provided?({:monkey => "2"}).should be_true
      self.monkey_provided?({}).should be_false
    end
    
    it "should raise an exception if given a non-existent method that does not end with _provided?" do
      lambda {
        self.do_something
      }.should raise_error
    end
  end
  
  it "should ask the PostType class for the list of post types" do
    Tumblr4Rails::PostType.should_receive(:post_type_names)
    post_types
  end
  
  it "should return an instance of Tumblr4Rails::HttpGateway when asked for the gateway" do
    gateway.should be_is_a(Tumblr4Rails::HttpGateway)
  end
  
  it "should ask the Tumblr4Rails module for its configuration to get the configuration" do
    Tumblr4Rails.should_receive(:configuration)
    configuration
  end
  
  it "should ask the tumblr configuration for the request type" do
    conf = mock("Config")
    conf.should_receive(:request_type)
    Tumblr4Rails.should_receive(:configuration).and_return(conf)
    request_type
  end
  
end
