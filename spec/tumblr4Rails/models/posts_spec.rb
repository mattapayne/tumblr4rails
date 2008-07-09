require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::Posts do
  
  before(:each) do
    @posts = Tumblr4Rails::Posts.new(posts_hash)
  end
  
  it "should include the Tumblr4Rails::ModelMethods module" do
    Tumblr4Rails::Posts.included_modules.should be_include(Tumblr4Rails::ModelMethods)
  end
  
  it "should create a tumblelog object if there is a tumblelog hash" do
    @posts.tumblelog.should_not be_nil
    @posts.tumblelog.name.should == "ggdggf"
  end
  
  it "should not create a tumblelog object if there is not tublelog hash" do
    posts = Tumblr4Rails::Posts.new({})
    posts.tumblelog.should be_nil
  end
  
  it "should not create any posts if there are no posts in the hash" do
    posts = Tumblr4Rails::Posts.new({})
    posts.should have(0).items
  end
  
  it "should create posts and add them to itself" do
    @posts.should have(2).items
  end
  
end
