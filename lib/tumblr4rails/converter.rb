require 'ostruct'

module Tumblr4Rails
 
  module Converter
    
    def self.included(klazz)
      klazz.send(:include, ConvertMethods)
    end
    
    def self.extended(klazz)
      klazz.extend(ConvertMethods)
    end
    
    module ConvertMethods
      
      @@gsub_map = {
        /conversation-line/ => "conversation-lines",
        /\s{1,}type=/ => " post-type=",
        /photo-url/ => "photo-urls",
        /\sid=/ => " tumblr-id=",
        /(\s{2,}|\n)/ => ""
      }.freeze
      
      def convert(data)
        return if data.blank?
        cleanup_data!(data)
        listener = parse_data(data)
        listener.posts.underscore_keys!
        Tumblr4Rails::Posts.new(listener.posts)
      end
      
      private
      
      def parse_data(data)
        listener = Tumblr4Rails::PostsListener.new
        REXML::Document.parse_stream(data, listener)
        listener
      end
      
      def cleanup_data!(data)
        @@gsub_map.each do |original, new|
          data.gsub!(original, new)
        end
      end
      
    end
    
  end
  
end
