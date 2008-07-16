module Tumblr4Rails
 
  class Converter
      
    @@gsub_map = {
      /conversation-line/ => "conversation-lines",
      /\s{1,}type=/ => " post-type=",
      /photo-url/ => "photo-urls",
      /\sid=/ => " tumblr-id=",
      /(\s{2,}|\n)/ => ""
    }.freeze
      
    def self.convert(data)
      return if data.blank?
      cleanup_data!(data)
      listener = parse_data(data)
      listener.posts.underscore_keys!
      Tumblr4Rails::Posts.new(listener.posts)
    end
      
    private
      
    def self.parse_data(data)
      listener = Tumblr4Rails::PostsListener.new
      REXML::Document.parse_stream(data, listener)
      listener
    end
      
    def self.cleanup_data!(data)
      @@gsub_map.each do |original, new|
        data.gsub!(original, new)
      end
    end
      
  end
  
end
