module Tumblr4Rails
  
  class VideoPost < Post
    
    attr_reader :source, :player
    attr_accessor :embed, :data, :title, :caption, :filename
    
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
      src = multipart? ? upload_data : embed
      Tumblr4Rails::Tumblr.create_video_post(src, title, caption, additional_params)
    end
    
    def upload_data
      pre_ensure("You must supply a filename." => (!filename.blank?),
        "You must provide the binary data for the video file" => (!data.blank?)) do
        Tumblr4Rails::Upload.new(filename, data)
      end
    end
    
    def multipart?
      embed.blank? && !data.blank?
    end
    
  end
  
end
