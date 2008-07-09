module Tumblr4Rails
  
  class ConversationPost < Post
    
    attr_reader :lines
    
    @@attr_map = {:conversation_title => :title, :conversation_text => :conversation}.freeze
    
    @@attr_accessors = [:conversation, :title].freeze
    
    def self.get(options={})
      Tumblr4Rails::Tumblr.conversation_posts(options)
    end
    
    private
    
    def attr_accessors
      @@attr_accessors
    end
    
    def do_save!(additional_params={})
      Tumblr4Rails::Tumblr.create_conversation_post(conversation, title, additional_params)
    end
    
    def after_initialized(attributes)
      return if attributes.blank?
      @lines = attributes[:conversation_lines].inject([]) {|arr, attr| 
        arr << Tumblr4Rails::ConversationLine.new(attr); arr} if has?(:conversation_lines, attributes)
    end
    
    def attribute_map
      @@attr_map
    end
    
  end
  
end
