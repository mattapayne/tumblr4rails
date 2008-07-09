module Tumblr4Rails
  
  class VideoPost < Post
    
    attr_reader :source, :player
    
    @@attr_map = {:video_caption => :caption, :video_source => :source, 
      :video_title => :title, :video_player => :player}.freeze
    
    @@attr_accessors = [:embed, :data, :title, :caption].freeze
    
    def self.get(options={})
      Tumblr4Rails::Tumblr.video_posts(options)
    end
    
    private
    
    def attr_accessors
      @@attr_accessors
    end
    
    def attribute_map
      @@attr_map
    end
    
    def do_save!(additional_params={})
      Tumblr4Rails::Tumblr.create_video_post(embed, data, title, caption, additional_params)
    end
    
  end
  
end
