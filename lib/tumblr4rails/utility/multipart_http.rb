#Based on code here:
#http://www.realityforge.org/articles/2006/03/02/upload-a-file-via-post-with-net-http

module Tumblr4Rails
  
  module MultipartHttp
      
    BOUNDARY = '349832898984244898448024464570528145'
    
    def multipart_post(uri, data)
      Net::HTTP.start(uri.host, uri.port).post2(uri.path,
        convert_to_multipart(data), 
        "Content-type" => "multipart/form-data; boundary=#{BOUNDARY}")
    end
    
    private
    
    def convert_to_multipart(data)
      return if data.blank?
      params = data.inject([]) do |arr, (key, value)|
        if value.is_a?(Tumblr4Rails::Upload)
          raise ArgumentError.new("A mime type must be provided.") if value.mime_type.blank?
          arr << file_to_multipart(key, value.filename, value.mime_type.to_s, value.content)
        else
          arr << text_to_multipart(key, value)
        end
        arr
      end
      params.collect {|p| '--' + BOUNDARY + "\r\n" + p}.join('') + "--" + BOUNDARY + "--\r\n"
    end
  
    def text_to_multipart(key,value)
      return "Content-Disposition: form-data; name=\"#{CGI::escape(key.to_s)}\"\r\n" + 
        "\r\n" + 
        "#{value}\r\n"
    end

    def file_to_multipart(key, filename, mime_type, content)
      return "Content-Disposition: form-data; name=\"#{CGI::escape(key.to_s)}\"; filename=\"#{filename}\"\r\n" +
        "Content-Transfer-Encoding: binary\r\n" +
        "Content-Type: #{mime_type}\r\n" + 
        "\r\n" + 
        "#{content}\r\n"
    end
    
  end
  
end
