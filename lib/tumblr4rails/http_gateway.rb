module Tumblr4Rails
  
  class ConnectionError < StandardError
    attr_reader :response

    def initialize(response, message = nil)
      @resp = response
      @message  = message
    end

    def to_s
      "Failed with #{@resp.code} #{@resp.message if response.respond_to?(:message)}"
    end
  end

  class TimeoutError < ConnectionError
    def initialize(message)
      @message = message
    end
    def to_s; @message ;end
  end
  
  class Redirection < ConnectionError
    def to_s; @resp['Location'] ? "#{super} => #{@resp['Location']}" : super; end    
  end 

  # 4xx Client Error
  class ClientError < ConnectionError; end
  
  # 400 Bad Request
  class BadRequest < ClientError; end
  
  # 401 Unauthorized
  class UnauthorizedAccess < ClientError; end
  
  # 403 Forbidden
  class ForbiddenAccess < ClientError; end
  
  # 404 Not Found
  class ResourceNotFound < ClientError; end
  
  # 409 Conflict
  class ResourceConflict < ClientError; end

  # 5xx Server Error
  class ServerError < ConnectionError; end

  class MethodNotAllowed < ClientError # :nodoc:
    def allowed_methods
      @resp['Allow'].split(',').map { |verb| verb.strip.downcase.to_sym }
    end
  end
  
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
    
    def http
      @http ||= Tumblr4Rails::Http.new
    end
  end
  
end
