module Tumblr4Rails
  
  class VideoPost < Post
    
    attr_reader :source, :player
    attr_accessor :embed, :data, :title, :caption
    
    @@attr_map = {:video_caption => :caption, :video_source => :source, 
      :video_title => :title, :video_player => :player}.freeze
    
    def self.get(options={})
      Tumblr4Rails::Tumblr.video_posts(options)
    end
    
    private
    
    def attribute_map
      @@attr_map
    end
    
    def do_save!(additional_params={})
      Tumblr4Rails::Tumblr.create_video_post(embed, data, title, caption, additional_params)
    end
    
  end
  
end
