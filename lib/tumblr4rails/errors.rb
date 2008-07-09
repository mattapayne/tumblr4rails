module Tumblr4Rails
  module Errors
    #This code is stolen shamelessly from ActiveResource
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
  end
end
