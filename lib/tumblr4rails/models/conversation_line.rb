module Tumblr4Rails
  
  class ConversationLine
    
    include Tumblr4Rails::ModelMethods
    
    attr_reader :name, :label, :content
    
    private
    
    def after_initialized(attributes)
      @readonly = true
    end
    
  end
  
end
