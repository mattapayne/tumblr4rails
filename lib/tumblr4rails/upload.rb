require 'mime/types'

module Tumblr4Rails
  
  class Upload
    
    attr_reader :filename, :mime_type, :content
    
    def initialize(filename, content, mime_type=nil)
      @filename, @content = filename, content
      @mime_type = mime_type.blank? ? get_mime_type : mime_type
    end
    
    private
    
    def get_mime_type
      unless @filename.blank?
        types = MIME::Types.type_for(@filename)
        unless types.blank?
          @mime_type = types.first.to_s
        end
      end
    end
    
  end
  
end
