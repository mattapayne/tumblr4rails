require File.dirname(__FILE__) + '/../../spec_helper'

describe "Tumblr4Rails::Feed" do
  
  it "should include the Tumblr4Rails::ModelMethods module" do
    Tumblr4Rails::Feed.included_modules.should be_include(Tumblr4Rails::ModelMethods)
  end
  
  it "should be frozen" do
    url = Tumblr4Rails::PhotoUrl.new
    url.should be_frozen
  end
  
end