require 'rexml/document'
require 'rexml/streamlistener'

module Tumblr4Rails
  
  class PostsListener
    
    include REXML::StreamListener
    
    attr_reader :posts
    attr_accessor :current_conversation, :current_post_property, 
      :processing_photo_url, :processing_conversation, :processing_post
    
    def initialize
      @posts = {}
      @start_tag_handlers = {
        Listener::TUMBLR => TagStartHandlers::TumblrHandler.new(self),
        Listener::TUMBLELOG => TagStartHandlers::TumblelogHandler.new(self),
        Listener::POSTS => TagStartHandlers::PostsHandler.new(self),
        Listener::POST => TagStartHandlers::PostHandler.new(self),
        Listener::FEEDS => TagStartHandlers::FeedsHandler.new(self),
        Listener::FEED => TagStartHandlers::FeedHandler.new(self),
        Listener::CONVERSATION => TagStartHandlers::ConversationHandler.new(self),
        Listener::PHOTO_URL => TagStartHandlers::PhotoUrlHandler.new(self)
      }
      @start_tag_handlers.default = TagStartHandlers::Handler.new(self) 
      @end_tag_handlers = {
        Listener::POST => TagEndHandlers::PostHandler.new(self),
        Listener::CONVERSATION => TagEndHandlers::ConversationHandler.new(self),
        Listener::PHOTO_URL => TagEndHandlers::PhotoUrlHandler.new(self)
      }
      @end_tag_handlers.default = TagEndHandlers::Handler.new(self)
      @text_handler = TextHandlers::Handler.new(self)
    end
    
    def tag_start(name, attributes)
      update_attrs!(attributes) unless attributes.blank?
      start_tag_handler(name.to_sym).handle(name.to_sym, attributes)
    end
    
    def tag_end(name)
      end_tag_handler(name.to_sym).handle
    end
    
    def text(text)
      handle_text(text)
    end
    
    def processing_post?
      processing_post
    end
    
    def processing_conversation?
      processing_conversation
    end
    
    def processing_photo_url?
      processing_photo_url
    end
    
    private
    
    def start_tag_handler(key)
      @start_tag_handlers[key]
    end
    
    def end_tag_handler(key)
      @end_tag_handlers[key]
    end
    
    def handle_text(text)
      @text_handler.handle(text)
    end
    
    def update_attrs!(attrs)
      attrs.underscore_keys!
      attrs.symbolize_keys!
    end
    
  end

end
