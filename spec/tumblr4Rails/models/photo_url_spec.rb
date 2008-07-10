require File.dirname(__FILE__) + '/../../spec_helper'

describe "Tumblr4Rails::PhotoUrl" do
  
  it "should include the Tumblr4Rails::Initializer module" do
    Tumblr4Rails::PhotoUrl.included_modules.should be_include(Tumblr4Rails::ModelMethods)
  end
  
  it "should be frozen" do
    url = Tumblr4Rails::PhotoUrl.new
    url.should be_frozen
  end
  
end