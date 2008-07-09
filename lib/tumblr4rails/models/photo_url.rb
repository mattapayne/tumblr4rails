module Tumblr4Rails
  
  class PhotoUrl
    
    include Tumblr4Rails::ModelMethods
    
    attr_reader :max_width, :url
    
  end
  
end
