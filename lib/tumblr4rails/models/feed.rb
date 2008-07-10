module Tumblr4Rails
  
  class Feed
    
    include Tumblr4Rails::ModelMethods
    
    attr_reader :tumblr_id, :url, :import_type, :next_update_in_seconds, 
      :title, :error_text
    
    private
    
    def after_initialized(attributes)
      @readonly = true
    end
    
  end
  
end
