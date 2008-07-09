require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::AudioPost do
  
  before(:each) do
    @post = Tumblr4Rails::AudioPost.new
    @resp = mock("Response")
    @resp.stub!(:code).and_return("200")
    @resp.stub!(:new_id).and_return("5435543")
  end
  
  it "should delegate the work to the Tumblr4Rails::Tumblr class when save! is called" do
    Tumblr4Rails::Tumblr.should_receive(:create_audio_post).and_return(@resp)
    @post.save!
  end
  
  it "should pass in the correct values when save! is called" do
    Tumblr4Rails::Tumblr.should_receive(:create_audio_post).
      with(@post.source, @post.data, @post.caption, {}).and_return(@resp)
    @post.save!
  end
  
  it "should pass in the correct values and additional values when save! is called" do
    Tumblr4Rails::Tumblr.should_receive(:create_audio_post).
      with(@post.source, @post.data, @post.caption, hash_including({:test => "1"})).
      and_return(@resp)
    @post.save!(:test => "1")
  end
  
  it "should delegate the work to the Tumblr4Rails::Tumblr class when get is called" do
    Tumblr4Rails::Tumblr.should_receive(:audio_posts)
    Tumblr4Rails::AudioPost.get
  end
  
  it "should pass additional options to the Tumblr4Rails::Tumblr class when get is called" do
    Tumblr4Rails::Tumblr.should_receive(:audio_posts).with(hash_including({:id => "12"}))
    Tumblr4Rails::AudioPost.get({:id => "12"})
  end
  
end