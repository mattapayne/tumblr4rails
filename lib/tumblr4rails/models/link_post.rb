module Tumblr4Rails
  
  class LinkPost < Post
    
    @@attr_map = {:link_text => :name, :link_url => :source_url, 
      :link_description => :description}.freeze
    
    @@attr_accessors = [:source_url, :name, :description].freeze
    
    attr_reader :bookmarklet
    
    def self.get(options={})
      Tumblr4Rails::Tumblr.link_posts(options)
    end
    
    private
    
    def attr_accessors
      @@attr_accessors
    end
    
    def attribute_map
      @@attr_map
    end
    
    def do_save!(additional_params={})
      Tumblr4Rails::Tumblr.create_link_post(source_url, name, description, additional_params)
    end
    
  end
  
end
