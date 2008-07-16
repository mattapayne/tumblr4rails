module Tumblr4Rails
  
  class QuotePost < Post
    
    attr_accessor :quote, :source
    
    @@attr_map = {:quote_text => :quote, :quote_source => :source}.freeze
    
    def self.get(options={})
      Tumblr4Rails::Reader.quote_posts(options)
    end
    
    private
    
    def attribute_map
      @@attr_map
    end
    
    def do_save!(additional_params={})
      Tumblr4Rails::Writer.create_quote_post(quote, source, additional_params)
    end
    
  end
  
end
