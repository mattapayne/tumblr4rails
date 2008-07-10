module Tumblr4Rails
  
  class PhotoUrl
    
    include Tumblr4Rails::ModelMethods
    
    attr_reader :max_width, :url
    
    private
    
    def readonly?
      true
    end
    
  end
  
end
