module Tumblr4Rails
  
  class RegularPost < Post
    
    @@attr_map = {:regular_title => :title, :regular_body => :body}.freeze
    
    @@attr_accessors = [:title, :body].freeze
    
    def self.get(options={})
      Tumblr4Rails::Tumblr.regular_posts(options)
    end
    
    private
    
    def attr_accessors
      @@attr_accessors
    end
    
    def attribute_map
      @@attr_map
    end
    
    def do_save!(additional_params={})
      Tumblr4Rails::Tumblr.create_regular_post(title, body, additional_params)
    end
    
  end
  
end
