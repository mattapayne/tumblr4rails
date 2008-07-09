module Tumblr4Rails
  
  module RequestType
    
    REQUEST = :request
    APPLICATION = :application
    
    def self.all
      [REQUEST, APPLICATION]
    end
    
    def self.request
      REQUEST
    end
    
    def self.application
      APPLICATION
    end
    
  end
  
end
