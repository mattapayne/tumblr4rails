require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::PhotoPost do
  
  before(:each) do
    @post = Tumblr4Rails::PhotoPost.new
    @resp = mock("Response")
    @resp.stub!(:code).and_return("200")
    @resp.stub!(:new_id).and_return("5435543")
  end
  
  it "should delegate the work to the Tumblr4Rails::Tumblr class when save! is called" do
    Tumblr4Rails::Tumblr.should_receive(:create_photo_post).and_return(@resp)
    @post.save!
  end
  
  it "should pass in the correct values when save! is called" do
    Tumblr4Rails::Tumblr.should_receive(:create_photo_post).
      with(@post.source, @post.data, @post.caption, {}).and_return(@resp)
    @post.save!
  end
  
  it "should pass in the correct values and additional values when save! is called" do
    Tumblr4Rails::Tumblr.should_receive(:create_photo_post).
      with(@post.source, @post.data, @post.caption, hash_including({:test => "1"})).
      and_return(@resp)
    @post.save!(:test => "1")
  end
  
  it "should delegate the work to the Tumblr4Rails::Tumblr class when get is called" do
    Tumblr4Rails::Tumblr.should_receive(:photo_posts)
    Tumblr4Rails::PhotoPost.get
  end
  
  it "should pass additional options to the Tumblr4Rails::Tumblr class when get is called" do
    Tumblr4Rails::Tumblr.should_receive(:photo_posts).with(hash_including({:id => "12"}))
    Tumblr4Rails::PhotoPost.get({:id => "12"})
  end
  
  describe "after_initialized" do
    
    it "should not proceed if the attributes are blank" do
      opts = photo_urls_hash
      opts.should_receive(:blank?).at_least(1).times.and_return(true)
      post = Tumblr4Rails::PhotoPost.new(opts)
      post.urls.should be_nil
    end
    
    it "should populate the urls collection if the attributes are not blank" do
      post = Tumblr4Rails::PhotoPost.new(photo_urls_hash)
      post.urls.should have(2).items
    end
    
  end
  
end