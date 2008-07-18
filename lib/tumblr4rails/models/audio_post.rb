module Tumblr4Rails

  class AudioPost < Post
    
    attr_reader :plays, :player
    attr_accessor :data, :caption, :filename
    
    @@attr_map = {:audio_caption => :caption, :audio_plays => :plays, 
      :audio_player => :player}.freeze
    
    def self.get(options={})
      Tumblr4Rails::Tumblr.audio_posts(options)
    end
    
    private
    
    def do_save!(additional_params={})
      Tumblr4Rails::Tumblr.create_audio_post(upload_data, caption, additional_params)
    end
    
    def attribute_map
      @@attr_map
    end
    
    def upload_data
      pre_ensure("You must supply a filename." => (!filename.blank?),
        "You must provide the binary data for the audio file" => (!data.blank?)) do
        Tumblr4Rails::Upload.new(filename, data)
      end
    end
    
  end

end
