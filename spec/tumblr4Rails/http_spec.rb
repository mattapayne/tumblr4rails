require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::Http do
  
  before(:each) do
    @http = Tumblr4Rails::Http.new
  end
  
  it "should include Tumblr4Rails::MultipartHttp" do
    Tumblr4Rails::Http.included_modules.should be_include(Tumblr4Rails::MultipartHttp)
  end
  
  it "should call the multipart post if multipart is true" do
    @http.should_receive(:multipart_post)
    @http.post("url", {}, true)
  end
  
  it "should call the simple post if multipart is false" do
    @http.should_receive(:simple_post)
    @http.post("url", {})
  end
  
end