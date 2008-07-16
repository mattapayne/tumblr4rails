module Tumblr4Rails

  module Listener
    
    TUMBLR = :tumblr
    TUMBLELOG = :tumblelog
    POSTS = :posts
    POST = :post
    FEED = :feed
    FEEDS = :feeds
    CONVERSATION = :"conversation-lines"
    PHOTO_URL = :"photo-urls"
    CONTENT = :content
    URL = :url
    VERSION = :version
    TOTAL = :total
    START = :start
    POST_TYPE = :post_type
    ALL_POSTS_ATTS = [TOTAL, START, POST_TYPE].freeze
    
    class HandlerBase
      
      def initialize(listener)
        @listener = listener
      end
      
      protected
      
      def listener
        @listener
      end
      
    end
    
  end
    
  module TextHandlers
   
    class Handler < Listener::HandlerBase
   
      def handle(text)
        if processing_post?
          value = listener.posts[Listener::POSTS].last[listener.current_post_property]
          listener.posts[Listener::POSTS].last[listener.current_post_property] = text if value.blank?
          listener.posts[Listener::POSTS].last[listener.current_post_property] = [value, text] if value.is_a?(String)
          listener.posts[Listener::POSTS].last[listener.current_post_property] << text if value.is_a?(Array)
        elsif processing_conversation?
          listener.current_conversation[Listener::CONTENT] = text
        elsif processing_photo_url?
          listener.posts[Listener::POSTS].last[Listener::PHOTO_URL].last[Listener::URL] = text
        end
      end
      
      private
    
      def processing_post?
        listener.processing_post? && !listener.processing_conversation? &&
          !listener.processing_photo_url?
      end
    
      def processing_conversation?
        listener.processing_post? && listener.processing_conversation? && 
          !listener.processing_photo_url?
      end
    
      def processing_photo_url?
        listener.processing_post? && listener.processing_photo_url? && 
          !listener.processing_conversation?
      end
    
    end
    
  end
  
  module TagEndHandlers
   
    class Handler < Listener::HandlerBase
    
      def handle
        #does nothing by default
      end
    
    end
  
    class PostHandler < Handler
    
      def handle
        listener.processing_post = false
      end
    
    end
  
    class ConversationHandler < Handler
    
      def handle
        listener.posts[Listener::POSTS].last[Listener::CONVERSATION] << listener.current_conversation
        listener.current_conversation = nil
        listener.processing_conversation = false
      end
    
    end
  
    class PhotoUrlHandler < Handler
    
      def handle
        listener.processing_photo_url = false
      end
    
    end
    
  end
  
  module TagStartHandlers
   
    class Handler < Listener::HandlerBase
    
      def handle(name, attributes)
        if listener.processing_post?
          listener.current_post_property = name
          unless listener.posts[Listener::POSTS].last.key?(name)
            listener.posts[Listener::POSTS].last[name] = nil
          end
        end
      end
    
    end
  
    class TumblrHandler < Handler
    
      def handle(name, attributes)
        listener.posts[Listener::VERSION] = attributes[Listener::VERSION]
      end
    
    end
  
    class TumblelogHandler < Handler
    
      def handle(name, attributes)
        listener.posts[Listener::TUMBLELOG] = attributes unless attributes.blank?
      end
    
    end
  
    class FeedsHandler < Handler
    
      def handle(name, attributes)
        listener.posts[Listener::TUMBLELOG][Listener::FEEDS] = []
      end
    
    end
  
    class FeedHandler < Handler
    
      def handle(name, attributes)
        listener.posts[Listener::TUMBLELOG][Listener::FEEDS] << attributes unless attributes.blank?
      end
    
    end
  
    class PostsHandler < Handler
      
      def handle(name, attributes)
        return if attributes.blank?
        Listener::ALL_POSTS_ATTS.each do |att| 
          listener.posts[att] = attributes[att] if (attributes.key?(att) && !attributes[att].blank?)
        end
      end
    
    end
  
    class PostHandler < Handler
    
      def handle(name, attributes)
        unless attributes.blank?
          listener.processing_post = true
          listener.posts[Listener::POSTS] << attributes if listener.posts.key?(Listener::POSTS)
          listener.posts[Listener::POSTS] = [attributes] unless listener.posts.key?(Listener::POSTS)
        end
      end
    
    end
  
    class ConversationHandler < Handler
    
      def handle(name, attributes)
        unless attributes.blank?
          listener.current_conversation = attributes
          listener.processing_conversation = true
          unless listener.posts[Listener::POSTS].last.key?(Listener::CONVERSATION)
            listener.posts[Listener::POSTS].last[Listener::CONVERSATION] = [] 
          end
        end
      end
    
    end
  
    class PhotoUrlHandler < Handler
    
      def handle(name, attributes)
        unless attributes.blank?
          listener.processing_photo_url = true
          if listener.posts[Listener::POSTS].last.key?(Listener::PHOTO_URL)
            listener.posts[Listener::POSTS].last[Listener::PHOTO_URL] << attributes
          else
            listener.posts[Listener::POSTS].last[Listener::PHOTO_URL] = [attributes]
          end
        end
      end
    
    end
   
  end
end
