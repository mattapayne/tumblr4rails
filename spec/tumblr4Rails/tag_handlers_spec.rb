require File.dirname(__FILE__) + '/../spec_helper'

describe "Tag Handlers" do
   
  before(:each) do
    @listener = Tumblr4Rails::PostsListener.new
  end
  
  describe "Text Handlers" do
    
    describe Tumblr4Rails::TextHandlers::Handler do
      
      before(:each) do
        @handler = Tumblr4Rails::TextHandlers::Handler.new(@listener)
        @listener.posts[:posts] = [post_hash]
      end
      
      describe "processing post and photo url, but not conversation" do
        
        before(:each) do
          @listener.processing_post = true         
          @listener.processing_conversation = false
          @listener.processing_photo_url = true
          @listener.current_conversation = nil
          @listener.posts[:posts].last[:"photo-urls"] = [photo_url_hash]
        end
        
        it "should set the url of the last photo url to the text" do
          @handler.handle("http://www.goo.ca")
          @listener.posts[:posts].last[:"photo-urls"].last[:url].should == "http://www.goo.ca"
        end
        
      end
      
      describe "processing post and conversation, but not photo url" do
        
        before(:each) do
          @listener.processing_post = true         
          @listener.processing_conversation = true
          @listener.processing_photo_url = false
          @listener.current_conversation = conversation_hash
        end
        
        it "should set the content of the current conversation to the text" do
          @handler.handle("monkey")
          @listener.current_conversation[:content].should == "monkey"
        end
        
      end
      
      describe "processing post, but not conversation or photo url" do
        
        before(:each) do
          @listener.processing_post = true         
          @listener.processing_conversation = false
          @listener.processing_photo_url = false
          @listener.current_conversation = nil
        end
        
        it "should set the value of the the current post property if it did not previosuly exist" do
          @listener.current_post_property = :test
          @handler.handle("test")
          @listener.posts[:posts].last[:test].should == "test"
        end
        
        it "should create an array containing the original value plus the new value if it previously existed" do
          @listener.posts[:posts].last[:post_type].should == "link"
          @listener.current_post_property = :post_type
          @handler.handle("test")
          @listener.posts[:posts].last[:post_type].should == ["link", "test"]
        end
        
        it "should append the value to the previous value if the previous value was an array" do
          @listener.posts[:posts].last[:post_type] = ["link", "something"]
          @listener.current_post_property = :post_type
          @handler.handle("test")
          @listener.posts[:posts].last[:post_type].should == ["link", "something", "test"]
        end
        
      end
    end
    
  end
  
  describe "End Tag Handlers" do
    
    describe Tumblr4Rails::TagEndHandlers::PostHandler do
      
      it "should set processing_post to false" do
        @listener.processing_post = true
        handler = Tumblr4Rails::TagEndHandlers::PostHandler.new(@listener)
        handler.handle
        @listener.should_not be_processing_post
      end
      
    end
    
    describe Tumblr4Rails::TagEndHandlers::PhotoUrlHandler do
      
      it "should set processing_photo_url to false" do
        @listener.processing_photo_url = true
        handler = Tumblr4Rails::TagEndHandlers::PhotoUrlHandler.new(@listener)
        handler.handle
        @listener.should_not be_processing_photo_url
      end
      
    end
    
    describe Tumblr4Rails::TagEndHandlers::ConversationHandler do
      
      before(:each) do
        @handler = Tumblr4Rails::TagEndHandlers::ConversationHandler.new(@listener)
        @listener.posts[:posts] = [post_hash]
        @listener.posts[:posts].last[:"conversation-lines"] = []
      end
      
      it "should set current_conversation to nil" do
        @listener.current_conversation = conversation_hash
        @handler.handle
        @listener.current_conversation.should be_nil
      end
      
      it "should set processing_conversation to false" do
        @listener.processing_conversation = true
        @handler.handle
        @listener.should_not be_processing_conversation
      end
      
      it "should add the current converstation to the conversations array" do
        @listener.current_conversation = conversation_hash
        @handler.handle
        @listener.posts[:posts].last[:"conversation-lines"].should have(1).items
      end
      
    end
    
  end
  
  describe "Start Tag Handlers" do
  
    describe Tumblr4Rails::TagStartHandlers::TumblrHandler do
    
      before(:each) do
        @handler = Tumblr4Rails::TagStartHandlers::TumblrHandler.new(@listener)
      end
    
      it "should set the version if the version is not blank" do
        @handler.handle(:version, {:version => "This is the version"})
        @listener.posts[:version].should == "This is the version"
      end
    
      it "should not set the version if the version does not exist" do
        @handler.handle(:version, {})
        @listener.posts[:version].should be_nil
      end
    
    end
  
    describe Tumblr4Rails::TagStartHandlers::TumblelogHandler do
    
      before(:each) do
        @handler = Tumblr4Rails::TagStartHandlers::TumblelogHandler.new(@listener)
      end
    
      it "should add the tumblelog if the tumblelog is not blank" do
        @handler.handle(:tumblelog, tumblelog_hash)
        @listener.posts[:tumblelog].should == tumblelog_hash
      end
    
      it "should not add the tumblelog if the tumblelog is blank" do
        @handler.handle(:tumblelog, {})
        @listener.posts.should_not be_key(:tumblelog)
      end
    
    end
  
    describe Tumblr4Rails::TagStartHandlers::FeedsHandler do
    
      before(:each) do
        @handler = Tumblr4Rails::TagStartHandlers::FeedsHandler.new(@listener)
        @listener.posts[:tumblelog] = tumblelog_hash
      end
    
      it "should add an empty feeds array to the tumblelog" do
        @handler.handle(:feeds, {})
        @listener.posts[:tumblelog][:feeds].should == []
      end
    
    end
  
    describe Tumblr4Rails::TagStartHandlers::FeedHandler do
    
      before(:each) do
        @handler = Tumblr4Rails::TagStartHandlers::FeedHandler.new(@listener)
        @listener.posts[:tumblelog] = tumblelog_hash
        @listener.posts[:tumblelog][:feeds] = []
      end
    
      it "should add a feed hash to the feeds array if the feed hash is not blank" do
        @handler.handle(:feed, feed_hash)
        @listener.posts[:tumblelog][:feeds].should be_include(feed_hash)
      end
    
      it "should not add a blank feed hash to the feeds array" do
        @handler.handle(:feed, {})
        @listener.posts[:tumblelog][:feeds].should be_empty
      end
    
    end
  
    describe Tumblr4Rails::TagStartHandlers::PostsHandler do
    
      def posts_hash(opts={})
        {:total => "2", :start => "0", :post_type => "regular"}.merge(opts)
      end
    
      def posts_hash_except(*other)
        posts_hash.reject {|k,v| other.flatten.include?(k)}
      end
    
      before(:each) do
        @handler = Tumblr4Rails::TagStartHandlers::PostsHandler.new(@listener)
      end
    
      it "should properly set total, start and post_type" do
        @handler.handle(:posts, posts_hash)
        @listener.posts[:total].should == "2"
        @listener.posts[:start].should == "0"
        @listener.posts[:post_type].should == "regular"
      end
    
      it "should not set any value that is blank" do
        @handler.handle(:posts, posts_hash(:total => ""))
        @listener.posts[:total].should be_nil
        @listener.posts[:start].should == "0"
        @listener.posts[:post_type].should == "regular"
      end
    
      it "should not attempt to set a non-existent key" do
        @handler.handle(:posts, posts_hash_except(:total, :start))
        @listener.posts[:total].should be_nil
        @listener.posts[:start].should be_nil
        @listener.posts[:post_type].should == "regular"
      end
    
      it "should not set any values if the posts hash is blank" do
        @handler.handle(:posts, {})
        @listener.posts[:total].should be_nil
        @listener.posts[:start].should be_nil
        @listener.posts[:post_type].should be_nil
      end
    
    end
  
    describe Tumblr4Rails::TagStartHandlers::PostHandler do
        
      before(:each) do
        @handler = Tumblr4Rails::TagStartHandlers::PostHandler.new(@listener)
      end
    
      it "should set processing_post to true if the post hash is not blank" do
        @handler.handle(:post, post_hash)
        @listener.should be_processing_post
      end
    
      it "should not set processing_post to true if the post hash is blank" do
        @handler.handle(:post, {})
        @listener.should_not be_processing_post
      end
    
      it "should create a posts array populated with the post hash if the posts array doesn't exist" do
        @listener.posts.should_not be_key(:posts)
        @handler.handle(:post, post_hash)
        @listener.should be_processing_post
        @listener.posts.should be_key(:posts)
        @listener.posts[:posts].should have(1).items
      end
    
      it "should add to the existing posts array if it was previously created" do
        @listener.posts[:posts] = [post_hash]
        @handler.handle(:post, post_hash)
        @listener.posts[:posts].should have(2).items
      end
    
    end
  
    describe Tumblr4Rails::TagStartHandlers::ConversationHandler do
       
      before(:each) do
        @handler = Tumblr4Rails::TagStartHandlers::ConversationHandler.new(@listener)
        @listener.posts[:posts] = [post_hash]
      end
    
      it "should do nothing if the  conversation hash is blank" do
        @handler.handle(:"conversation-lines", {})
        @listener.current_conversation.should be_nil
        @listener.should_not be_processing_conversation
        @listener.posts[:posts].last.should_not be_key(:"conversation-lines")
      end
    
      it "should set current_conversation to the passed in hash if the hash is not blank" do
        @handler.handle(:"conversation-lines", conversation_hash)
        @listener.current_conversation.should == conversation_hash
      end
    
      it "should set processing_conversation to true if the hash is not blank" do
        @handler.handle(:"conversation-lines", conversation_hash)
        @listener.should be_processing_conversation
      end
   
      it "should create an empty array under the last post to hold conversations" do
        @listener.posts[:posts].last.should_not be_key(:"conversation-lines")
        @handler.handle(:"conversation-lines", conversation_hash)
        @listener.posts[:posts].last[:"conversation-lines"].should == []
      end
    
      it "should not create an empty array to hold conversations if it already exists" do
        @listener.posts[:posts].last[:"conversation-lines"] = [conversation_hash]
        @handler.handle(:"conversation-lines", conversation_hash)
        @listener.posts[:posts].last[:"conversation-lines"].should have(1).items
      end
    
    end
  
    describe Tumblr4Rails::TagStartHandlers::PhotoUrlHandler do
    
      before(:each) do
        @handler = Tumblr4Rails::TagStartHandlers::PhotoUrlHandler.new(@listener)
        @listener.posts[:posts] = [post_hash]
      end
    
      it "should do nothing is the photo_url hash is blank" do
        @handler.handle(:"photo-urls", {})
        @listener.posts[:posts].last.should_not be_key(:"photo-urls")
      end
    
      it "should set processing_photo_url to true" do
        @handler.handle(:"photo-urls", photo_url_hash)
        @listener.should be_processing_photo_url
      end
    
      it "should create a photo urls array if it does not already exist" do
        @listener.posts[:posts].last.should_not be_key(:"photo-urls")
        @handler.handle(:"photo-urls", photo_url_hash)
        @listener.posts[:posts].last[:"photo-urls"].should == [photo_url_hash]
      end
    
      it "should add the photo_url hash to the photo_urls array if it already exists" do
        @listener.posts[:posts].last[:"photo-urls"] = [photo_url_hash]
        @handler.handle(:"photo-urls", photo_url_hash)
        @listener.posts[:posts].last[:"photo-urls"].should have(2).items
      end
    
    end
    
  end
  
end
