require 'net/http'
require 'cgi'

module Tumblr4Rails
  
  class Http
    
    include Tumblr4Rails::MultipartHttp
    
    def post(uri, data, multipart=false)
      if multipart
        log("Performing multipart POST. Data: #{data.reject {|k,v| v.is_a?(Tumblr4Rails::Upload)}}.")
        return multipart_post(uri, data)
      end
      return simple_post(uri, data)
    end
    
    def get(uri)
      log("Performing GET to #{uri}.")
      Net::HTTP.start(uri.host, uri.port) {|http| http.get(uri.path_with_querystring)}
    end
    
    private
    
    def simple_post(uri, data)
      log("Performing a simple POST. Data: #{data.inspect}.")
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(data)
      Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
    end
    
    def log(msg)
      if Rails.logger
        Rails.logger.info(msg)
      end
    end
    
  end
  
end
