module Tumblr4Rails
    
  class HttpGateway
    include Tumblr4Rails::PseudoDbc
    
    def get_posts(url)
      pre_ensure("The URL cannot be blank." => (!url.blank?)) do
        call_api(:get, url)
      end
    end
      
    def post_new_post(url, data)
      pre_ensure("The URL cannot be blank." => (!url.blank?), 
        "To create a Post, data is required." => (!data.blank?)) do
        call_api(:post, url, data)
      end
    end
    
    def execute_query(url, args)
      pre_ensure("The URL cannot be blank." => (!url.blank?), 
        "To make a query, data is required." => (!args.blank?)) do
        call_api(:post, url, args)
      end
    end
     
    private
    
    def call_api(method, url, post_data={})
      response = nil
      case method
      when :post
        response = http.post(URI.parse(url), post_data, (post_data.delete(:multipart) || false))
      when :get
        response = http.get(URI.parse(url))
      end
      response
    end
    
    def http
      @http ||= Tumblr4Rails::Http.new
    end
  end
  
end
