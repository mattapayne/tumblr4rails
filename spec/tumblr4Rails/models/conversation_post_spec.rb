require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::ConversationPost do
  
  before(:each) do
    @post = Tumblr4Rails::ConversationPost.new
    @resp = mock("Response")
    @resp.stub!(:code).and_return("200")
    @resp.stub!(:new_id).and_return("5435543")
  end
  
  it "should delegate the work to the Tumblr4Rails::Tumblr class when save! is called" do
    Tumblr4Rails::Tumblr.should_receive(:create_conversation_post).and_return(@resp)
    @post.save!
  end
  
  it "should pass in the correct values when save! is called" do
    Tumblr4Rails::Tumblr.should_receive(:create_conversation_post).
      with(@post.conversation, @post.title, {}).and_return(@resp)
    @post.save!
  end
  
  it "should pass in the correct values and additional values when save! is called" do
    Tumblr4Rails::Tumblr.should_receive(:create_conversation_post).
      with(@post.conversation, @post.title, hash_including({:test => "1"})).and_return(@resp)
    @post.save!(:test => "1")
  end
  
  it "should delegate the work to the Tumblr4Rails::Tumblr class when get is called" do
    Tumblr4Rails::Tumblr.should_receive(:conversation_posts)
    Tumblr4Rails::ConversationPost.get
  end
  
  it "should pass additional options to the Tumblr4Rails::Tumblr class when get is called" do
    Tumblr4Rails::Tumblr.should_receive(:conversation_posts).with(hash_including({:id => "12"}))
    Tumblr4Rails::ConversationPost.get({:id => "12"})
  end
  
  describe "after_initialized" do
    
    it "should not proceed if the attributes are blank" do
      opts = conversation_lines_hash
      opts.should_receive(:blank?).at_least(1).times.and_return(true)
      post = Tumblr4Rails::ConversationPost.new(opts)
      post.lines.should be_nil
    end
    
    it "should populate the lines collection if the attributes are not blank" do
      post = Tumblr4Rails::ConversationPost.new(conversation_lines_hash)
      post.lines.should have(2).items
    end
    
  end
  
end