require 'net/http'
require 'cgi'

module Tumblr4Rails
  
  class Http
    
    include Tumblr4Rails::MultipartHttp
    
    def post(uri, data, multipart=false)
      if multipart
        return multipart_post(uri, data)
      end
      return simple_post(uri, data)
    end
    
    def get(uri)
      Net::HTTP.start(uri.host, uri.port) {|http| http.get(uri.path_with_querystring)}
    end
    
    private
    
    def simple_post(uri, data)
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(data)
      Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
    end
    
  end
  
end
