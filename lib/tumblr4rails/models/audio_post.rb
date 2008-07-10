module Tumblr4Rails

  class AudioPost < Post
    
    attr_reader :plays, :player
    attr_accessor :source, :data, :caption
    
    @@attr_map = {:audio_caption => :caption, :audio_plays => :plays, 
      :audio_player => :player}.freeze
    
    def self.get(options={})
      Tumblr4Rails::Tumblr.audio_posts(options)
    end
    
    private
    
    def do_save!(additional_params={})
      Tumblr4Rails::Tumblr.create_audio_post(source, data, caption, additional_params)
    end
    
    def attribute_map
      @@attr_map
    end
    
  end

end
