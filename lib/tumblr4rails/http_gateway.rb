require 'net/http'
require 'cgi'

module Tumblr4Rails
  
  class HttpGateway
    include Tumblr4Rails::Errors
    
    @@logger = nil
    
    def self.logger=(logger)
      @@logger = logger
    end
   
    def get(url)
      request(:get, url)
    end
      
    #Assumes that credentials have been set by the caller
    def post(url, data={})
      request(:post, url, data)
    end
     
    private
    
    def log_info(msg)
      @@logger.info(msg) if @@logger
    end
    
    def request(method, url, data=nil)
      url = URI.parse(url)
      log_info("#{self.class.name} - Performing #{method.to_s.upcase} to url: #{url}")
      request = nil
      case method
      when :post
        raise ArgumentError.new("POST data is required.") if data.blank?
        log_info("POST data: #{data.inspect}.")
        request = Net::HTTP::Post.new(url.path)
        request.set_form_data(data)
      when :get
        request = Net::HTTP::Get.new(url.path_with_querystring)
      end
      response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
      handle_response(response)
    rescue Timeout::Error => e
      raise TimeoutError.new(e.message)
    end
    
    private
    
    def handle_response(response)
      case response.code.to_i
      when 301,302
        raise(Redirection.new(response))
      when 200...400
        response
      when 400
        raise(BadRequest.new(response))
      when 401
        raise(UnauthorizedAccess.new(response))
      when 403
        raise(ForbiddenAccess.new(response))
      when 404
        raise(ResourceNotFound.new(response))
      when 405
        raise(MethodNotAllowed.new(response))
      when 409
        raise(ResourceConflict.new(response))
      when 422
        raise(ResourceInvalid.new(response))
      when 401...500
        raise(ClientError.new(response))
      when 500...600
        raise(ServerError.new(response))
      else
        raise(ConnectionError.new(response, "Unknown response code: #{response.code}"))
      end
    end
    
  end
  
end
