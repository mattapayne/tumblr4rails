module Tumblr4Rails
  
  class UploadPermission
    
    attr_reader :code
    
    def initialize(code, body)
      @code, @body = code, body
    end
    
    def login_url
      unless permitted?
        @body
      end
    end
    
    def permitted?
      @code.to_i == 200
    end
    
    def max_allowed_bytes
      if permitted?
        @body.blank? ? 0 : @body.to_i
      end
    end
    
  end
end
