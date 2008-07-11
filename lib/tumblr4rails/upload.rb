module Tumblr4Rails
  
  class Upload
   
    @@default_mime_types = {
      ".jpg"=>"image/jpeg",
      ".jpeg"=>"image/jpeg",
      ".wmv"=>"video/x-msvideo",
      ".gif"=>"image/gif",
      ".bmp"=>"image/bmp",
      ".png"=>"image/png",
      ".mp3"=>"audio/mpeg",
      ".xml"=>"application/xml"
    }.freeze
    
    attr_reader :filename, :mime_type, :content
    
    def initialize(filename, content, mime_type=nil)
      @filename, @content = filename, content
      @mime_type = mime_type.blank? ? get_mime_type : mime_type
    end
    
    private
    
    def get_mime_type
      lookup_mime_type(File.extname(@filename))
    end
    
    def lookup_mime_type(extension)
      types = @@default_mime_types.dup
      unless Tumblr4Rails.configuration.upload_mime_types.blank?
         types.merge!(Tumblr4Rails.configuration.upload_mime_types)
      end
      types[extension.downcase]
    end
    
  end
  
end
