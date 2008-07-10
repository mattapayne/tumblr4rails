module Tumblr4Rails
  
  class PhotoPost < Post
  
    attr_reader :urls
    attr_accessor :source, :data, :caption
    
    @@attr_map = {:photo_caption => :caption}.freeze
   
    def self.get(options={})
      Tumblr4Rails::Tumblr.photo_posts(options)
    end
    
    private

    def do_save!(additional_params={})
      Tumblr4Rails::Tumblr.create_photo_post(source, data, caption, additional_params)
    end
    
    def after_initialized(attributes)
      @urls = []
      @urls = attributes[:photo_urls].inject([]){|arr, attrs| 
        arr << Tumblr4Rails::PhotoUrl.new(attrs); arr} if has?(:photo_urls, attributes)
      @urls.freeze
    end
    
    def attribute_map
      @@attr_map
    end

  end
  
end
