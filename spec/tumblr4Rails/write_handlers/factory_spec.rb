require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::WriteOptions::Factory do
  
  def types
    [:regular, :link, :quote, :photo, :video, :audio, 
      :conversation, :authenticate, "check-vimeo", "check-audio"]
  end
  
  it "should be able to get a handler for any good type" do
    types.each {|t| 
      Tumblr4Rails::WriteOptions::Factory.handler_for(t, {}).should_not be_nil}
  end
  
  it "should return nil if the type is bad" do
    Tumblr4Rails::WriteOptions::Factory.handler_for(:xxx, {}).should be_nil
  end
  
  it "should not be able to be instantiated via new" do
    lambda {
      Tumblr4Rails::WriteOptions::Factory.new
    }.should raise_error
  end
  
end