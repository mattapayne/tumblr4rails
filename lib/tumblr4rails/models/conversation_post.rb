module Tumblr4Rails
  
  class ConversationPost < Post
    
    attr_reader :lines
    attr_accessor :conversation, :title
    
    @@attr_map = {:conversation_title => :title, :conversation_text => :conversation}.freeze
    
    def self.get(options={})
      Tumblr4Rails::Reader.conversation_posts(options)
    end
    
    private
    
    def do_save!(additional_params={})
      Tumblr4Rails::Writer.create_conversation_post(conversation, title, additional_params)
    end
    
    def after_initialized(attributes)
      @lines = []
      @lines = attributes[:conversation_lines].inject([]) {|arr, attr| 
        arr << Tumblr4Rails::ConversationLine.new(attr); arr} if has?(:conversation_lines, attributes)
      @lines.freeze
    end
    
    def attribute_map
      @@attr_map
    end
    
  end
  
end
