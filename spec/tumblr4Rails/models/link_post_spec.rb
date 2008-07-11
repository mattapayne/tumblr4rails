require File.dirname(__FILE__) + '/../../spec_helper'

describe "Tumblr4Rails::LinkPost" do
  
  before(:each) do
    @post = Tumblr4Rails::LinkPost.new
    @resp = create_mock_write_response
  end
  
  it "should delegate the work to the Tumblr4Rails::Tumblr class when save! is called" do
    Tumblr4Rails::TumblrWriter.should_receive(:create_link_post).and_return(@resp)
    @post.save!
  end
  
  it "should pass in the correct values to Tumblr4Rails::TumblrWriter when save! is called" do
    Tumblr4Rails::TumblrWriter.should_receive(:create_link_post).
      with(@post.url, @post.name, @post.description, {}).and_return(@resp)
    @post.save!
  end
  
  it "should pass in the correct values and additional values to Tumblr4Rails::TumblrWriter when save! is called" do
    Tumblr4Rails::TumblrWriter.should_receive(:create_link_post).
      with(@post.url, @post.name, @post.description, hash_including({:test => "1"})).
      and_return(@resp)
    @post.save!(:test => "1")
  end
  
  it "should delegate the work to the Tumblr4Rails::TumblrReader class when get is called" do
    Tumblr4Rails::TumblrReader.should_receive(:link_posts)
    Tumblr4Rails::LinkPost.get
  end
  
  it "should pass additional options to the Tumblr4Rails::TumblrReader class when get is called" do
    Tumblr4Rails::TumblrReader.should_receive(:link_posts).with(hash_including({:id => "12"}))
    Tumblr4Rails::LinkPost.get({:id => "12"})
  end
  
end