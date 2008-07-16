module Tumblr4Rails
  
  module WriteOptions
    
    class Factory
      
      @@handlers = {
        :regular => Tumblr4Rails::WriteOptions::RegularPostHandler,
        :audio => Tumblr4Rails::WriteOptions::AudioPostHandler,
        :conversation => Tumblr4Rails::WriteOptions::ConversationPostHandler,
        :link => Tumblr4Rails::WriteOptions::LinkPostHandler,
        :photo => Tumblr4Rails::WriteOptions::PhotoPostHandler,
        :quote => Tumblr4Rails::WriteOptions::QuotePostHandler,
        :video => Tumblr4Rails::WriteOptions::VideoPostHandler,
        :authenticate => Tumblr4Rails::WriteOptions::QueryHandler,
        :"check-vimeo" => Tumblr4Rails::WriteOptions::QueryHandler,
        :"check-audio" => Tumblr4Rails::WriteOptions::QueryHandler
      }.freeze
      
      def self.handler_for(type, options)
        if @@handlers.key?(type.to_sym)
          @@handlers[type.to_sym].new(options)
        end
      end
    
      private_class_method(:new)
      
    end
    
  end
  
end
