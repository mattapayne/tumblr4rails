require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::PostFactory do
  
  def options(other={})
    {"post_type" => "regular"}.merge(other)
  end
  
  it "should symbolize the keys of the options hash" do
    opts = options
    opts.should_receive(:symbolize_keys!)
    Tumblr4Rails::PostFactory.create_post(opts)
  end
  
  it "should create a post with attributes that include readonly" do
    opts = options
    Tumblr4Rails::RegularPost.should_receive(:new).with(hash_including(:readonly => true))
    Tumblr4Rails::PostFactory.create_post(opts)
  end
  
  it "should return nil if the post_type doesn't exist" do
    opts = options("post_type" => "blah")
    Tumblr4Rails::PostFactory.create_post(opts).should be_nil
  end
  
end
