require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::PostsListener do
  
  before(:each) do
    @listener = Tumblr4Rails::PostsListener.new
  end
  
  it "should be instantiated with an empty posts hash" do
    @listener.posts.should be_empty
  end
  
  it "should underscore and symbolize the attribute keys when tag_start is called" do
    @listener.should_receive(:update_attrs!)
    @listener.tag_start("post", post_hash)
  end
  
  it "should be processing a post when the post start tag has been processed" do
    @listener.tag_start("post", post_hash)
    @listener.should be_processing_post
  end
  
  it "should be processing a conversation when the conversation start tag has been processed" do
    @listener.posts[:posts] = [post_hash]
    @listener.tag_start("conversation-lines", conversation_lines_hash)
    @listener.should be_processing_conversation
    @listener.current_conversation.should_not be_nil
  end
  
  it "should be processing a photo_url when the photo url start tag has been processed" do
    @listener.posts[:posts] = [post_hash]
    @listener.posts[:posts].last[:"photo_urls"] = []
    @listener.tag_start("photo-urls", photo_url_hash)
    @listener.should be_processing_photo_url
  end
  
  it "should stop processing a post when the post end tag is encountered" do
    @listener.processing_post = true
    @listener.tag_end("post")
    @listener.should_not be_processing_post
  end
  
  it "should stop processing a conversation when the conversation end tag is encountered" do
    @listener.posts[:posts] = [post_hash]
    @listener.posts[:posts].last[:"conversation-lines"] = []
    @listener.processing_conversation = true
    @listener.current_conversation = Object.new
    @listener.tag_end("conversation-lines")
    @listener.should_not be_processing_conversation
    @listener.current_conversation.should be_nil
  end
  
  it "should stop processing a conversation when the conversation end tag is encountered" do
    @listener.processing_photo_url = true
    @listener.tag_end("photo-urls")
    @listener.should_not be_processing_photo_url
  end
  
end
