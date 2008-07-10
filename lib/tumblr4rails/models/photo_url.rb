module Tumblr4Rails
  
  class PhotoUrl
    
    include Tumblr4Rails::ModelMethods
    
    attr_reader :max_width, :url
    
    private
    
    def after_initialized(attributes)
      @readonly = true
    end
    
  end
  
end
