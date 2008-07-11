require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::MultipartHttp do
  include Tumblr4Rails::MultipartHttp
  
  before(:each) do
    @upload = Tumblr4Rails::Upload.new("test.jpeg", "dfdfasfasfsdfsdf")
  end
  
  it "should properly convert a textual key/value pair to a multipart" do
    hash = {:one => "test", :two => "test2"}
    multi = convert_to_multipart(hash)
      multi.should_not be_nil
  end
  
  it "should properly convert an upload to a multipart" do
    hash = {:one => "test", :two => "test2", :data => @upload}
    multi = convert_to_multipart(hash)
    multi.should_not be_nil
  end
  
  it "should return nil if the hash passed in is blank" do
    convert_to_multipart({}).should be_nil
  end
  
end