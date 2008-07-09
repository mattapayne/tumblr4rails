module Tumblr4Rails
  
  class ReadOnlyModelException < RuntimeError
    
    def initialize(message)
      super
    end
    
  end
  
end