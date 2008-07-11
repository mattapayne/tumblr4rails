module Tumblr4Rails
  
  class LinkPost < Post
    
    @@attr_map = {:link_text => :name, :link_url => :source_url, 
      :link_description => :description}.freeze
    
    attr_reader :bookmarklet
    attr_accessor :source_url, :name, :description
    
    def self.get(options={})
      Tumblr4Rails::TumblrReader.link_posts(options)
    end
    
    private

    def attribute_map
      @@attr_map
    end
    
    def do_save!(additional_params={})
      Tumblr4Rails::TumblrWriter.create_link_post(source_url, name, description, additional_params)
    end
    
  end
  
end
