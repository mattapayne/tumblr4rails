require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::Upload do
  
  it "should attempt to determine the mime type if it is not provided" do
    upload = Tumblr4Rails::Upload.new("test.xml", "ddfsdfs")
    upload.mime_type.to_s.should == "application/xml"
  end
  
  it "should have a nil mime type if the mime type was not provided and could not be determined" do
    upload = Tumblr4Rails::Upload.new("test.xxx", "ddfsdfs")
    upload.mime_type.should be_nil
  end
  
  it "should have the mime type provided if specified in the constructor" do
    upload = Tumblr4Rails::Upload.new("", "ddfsdfs", "application/xml")
    upload.mime_type.to_s.should == "application/xml"
  end
  
end