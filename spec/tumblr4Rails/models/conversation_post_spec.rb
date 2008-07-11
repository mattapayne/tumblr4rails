require File.dirname(__FILE__) + '/../../spec_helper'

describe "Tumblr4Rails::ConversationPost" do
  
  before(:each) do
    @post = Tumblr4Rails::ConversationPost.new
    @resp = create_mock_write_response
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
      with(@post.conversation, @post.title, 
      hash_including({:generator => "test"})).and_return(@resp)
    @post.save!(:generator => "test")
  end
  
  it "should delegate the work to the Tumblr4Rails::Tumblr class when get is called" do
    Tumblr4Rails::Tumblr.should_receive(:conversation_posts)
    Tumblr4Rails::ConversationPost.get
  end
  
  it "should pass additional options to the Tumblr4Rails::Tumblr class when get is called" do
    Tumblr4Rails::Tumblr.should_receive(:conversation_posts).with(hash_including({:id => "12"}))
    Tumblr4Rails::ConversationPost.get({:id => "12"})
  end
  
  it "should freeze the collection of conversation lines even when new" do
    @post.lines.should be_frozen
  end
  
  describe "after_initialized" do
    
    it "should not proceed if the attributes are blank" do
      opts = conversation_lines_hash
      opts.should_receive(:blank?).at_least(1).times.and_return(true)
      post = Tumblr4Rails::ConversationPost.new(opts)
      post.lines.should == []
    end
    
    it "should freeze the conversation lines after processing them" do
      post = Tumblr4Rails::ConversationPost.new(conversation_lines_hash)
      post.lines.should be_frozen
    end
    
    it "should populate the lines collection if the attributes are not blank" do
      post = Tumblr4Rails::ConversationPost.new(conversation_lines_hash)
      post.lines.should have(2).items
    end
    
  end
  
end