require File.dirname(__FILE__) + '/../../spec_helper'

describe "Tumblr4Rails::RegularPost" do
  
  before(:each) do
    @post = Tumblr4Rails::RegularPost.new
    @resp = create_mock_write_response
  end
  
  it "should delegate the work to the Tumblr4Rails::Writer class when save! is called" do
    Tumblr4Rails::Writer.should_receive(:create_regular_post).and_return(@resp)
    @post.save!
  end
  
  it "should pass in the correct values when save! is called" do
    Tumblr4Rails::Writer.should_receive(:create_regular_post).
      with(@post.title, @post.body, {}).and_return(@resp)
    @post.save!
  end
  
  it "should pass in the correct values and additional values when save! is called" do
    Tumblr4Rails::Writer.should_receive(:create_regular_post).
      with(@post.title, @post.body, hash_including({:test => "1"})).and_return(@resp)
    @post.save!(:test => "1")
  end
  
  it "should delegate the work to the Tumblr4Rails::Reader class when get is called" do
    Tumblr4Rails::Reader.should_receive(:regular_posts)
    Tumblr4Rails::RegularPost.get
  end
  
  it "should pass additional options to the Tumblr4Rails::Reader class when get is called" do
    Tumblr4Rails::Reader.should_receive(:regular_posts).with(hash_including({:id => "12"}))
    Tumblr4Rails::RegularPost.get({:id => "12"})
  end
  
end