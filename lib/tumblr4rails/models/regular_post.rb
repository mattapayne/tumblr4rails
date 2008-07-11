module Tumblr4Rails
  
  class RegularPost < Post
    
    attr_accessor :title, :body
    
    @@attr_map = {:regular_title => :title, :regular_body => :body}.freeze
    
    def self.get(options={})
      Tumblr4Rails::TumblrReader.regular_posts(options)
    end
    
    private
    
    def attribute_map
      @@attr_map
    end
    
    def do_save!(additional_params={})
      Tumblr4Rails::TumblrWriter.create_regular_post(title, body, additional_params)
    end
    
  end
  
end
