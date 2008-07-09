require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::UploadPermission do
  
  it "should return true for permitted? if the response code is 200" do
    resp = Tumblr4Rails::UploadPermission.new("200", "343443")
    resp.should be_permitted
  end
  
  it "should return false for permitted? if the response code is not 200" do
    resp = Tumblr4Rails::UploadPermission.new("403", "http://login.tumblr.com")
    resp.should_not be_permitted
  end
  
  it "should return the max allowed upload bytes if permitted? is true" do
    resp = Tumblr4Rails::UploadPermission.new("200", "343443")
    resp.max_allowed_bytes.should == 343443
  end
  
  it "should return nil for allowed bytes if not permitted" do
    resp = Tumblr4Rails::UploadPermission.new("403", "http://login.tumblr.com")
    resp.max_allowed_bytes.should be_nil
  end
  
  it "should have a login url if not permitted" do
    resp = Tumblr4Rails::UploadPermission.new("403", "http://login.tumblr.com")
    resp.login_url.should == "http://login.tumblr.com"
  end
  
  it "should have a nil login url if it is permitted" do
    resp = Tumblr4Rails::UploadPermission.new("200", "343443")
    resp.login_url.should be_nil
  end
  
end
