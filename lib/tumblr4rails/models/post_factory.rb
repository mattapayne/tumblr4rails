module Tumblr4Rails
  
  class PostFactory
    
    @@map = {
      "regular" => Tumblr4Rails::RegularPost,
      "audio" => Tumblr4Rails::AudioPost,
      "conversation" => Tumblr4Rails::ConversationPost,
      "link" => Tumblr4Rails::LinkPost,
      "photo" => Tumblr4Rails::PhotoPost,
      "quote" => Tumblr4Rails::QuotePost,
      "video" => Tumblr4Rails::VideoPost
    }.freeze
    
    def self.create_post(attributes)
      attributes.symbolize_keys!
      if @@map.key?(attributes[:post_type])
        klazz = @@map[attributes[:post_type]]
        unless klazz.blank?
          attributes[:readonly] = true
          obj = klazz.new(attributes)
          obj
        end
      end
    end
    
  end
  
end
