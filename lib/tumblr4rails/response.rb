module Tumblr4Rails
  
  class Response
    
    attr_reader :code, :message, :new_id
    
    def initialize(code, message, new_id)
      @code, @message, @new_id = code, message, new_id
    end
    
  end
  
end
