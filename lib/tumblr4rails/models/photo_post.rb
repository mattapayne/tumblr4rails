module Tumblr4Rails
  
  class PhotoPost < Post
  
    attr_reader :urls
    attr_accessor :source, :data, :caption, :click_through_url, :filename
    
    @@attr_map = {:photo_caption => :caption}.freeze
   
    def self.get(options={})
      Tumblr4Rails::Tumblr.photo_posts(options)
    end
    
    private

    def do_save!(additional_params={})
      src = multipart? ? upload_data : source
      Tumblr4Rails::Tumblr.create_photo_post(src, caption, click_through_url, additional_params)
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
    
    def upload_data
      pre_ensure("You must supply a filename." => (!filename.blank?),
        "You must provide the binary data for the photo file" => (!data.blank?)) do
        Tumblr4Rails::Upload.new(filename, data)
      end
    end
    
    def multipart?
      source.blank? && !data.blank?
    end
  end
  
end
