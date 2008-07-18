module Tumblr4Rails
  
  module Reader
    
    def self.included(klazz)
      klazz.send(:include, ReadMethods)
    end
    
    def self.extended(klazz)
      klazz.extend(ReadMethods)
    end
    
    @@read_methods = [ [:all_posts, :all], [:regular_posts, :regular], 
      [:photo_posts, :photo], [:quote_posts, :quote], [:link_posts, :link], 
      [:conversation_posts, :conversation], [:audio_posts, :audio], 
      [:video_posts, :video] ].freeze
    
    @@read_methods.each do |tup|
      class_eval(%{
              def #{tup.first}(options={})
                options = options.merge(:type => :#{tup.last})
                posts(options)
              end
        })
    end
      
    module ReadMethods
      
      include Tumblr4Rails::PseudoDbc
      
      def get_by_id(id, json=false, callback=nil)
        return if id.blank?
        posts = posts(:id => id, :json => json, :callback => callback)
        return posts if (json || posts && posts.size > 1)
        return posts.first
      end
      
      #Options:
      #:type => The type of post (:regular, :quote, :photo, :link, :conversation, :video, :audio)
      #:limit => The number of posts to return (minimum 1, maximum 50) - alias for num
      #:index => The post offset to start from. - alias for start
      #:start => The post offset to start from
      #:id => The id of the specific post. If this is used, all other params are ignored.
      #:json => if json => true, the response will be a json string
      #:callback => using in conjunction with json => true, specifies a javascript method to
      # execute instead of setting a javascript variable
      def posts(options)
        return if options.blank?
        options = cleanup_read_params!(options)
        json = (options.delete(:json) || false)
        response = get_response(options, json)
        return response.body if json
        return Tumblr4Rails::Converter.convert(response.body)
      end
      
      private
      
      def get_response(options, json)
        return gateway.get_posts(generate_read_url(options, json))
      end
      
      #The XXX_provided? methods are handled by a method_missing in read_write_common.rb
      def cleanup_read_params!(options)
        options = options.symbolize_keys
        ensure_read_url!(options) unless read_url_provided?(options)
        Tumblr4Rails::ReadOptions::ReadHandler.new(options).process!
      end
      
      def generate_read_url(options, json)
        url = "#{options.delete(:read_url)}#{json ? '/json' : ''}"
        url += "?#{options.to_param}" unless options.blank?
        url
      end
      
      def ensure_read_url!(options)
        pre_ensure("Could not determine Tumblr read_url" => (!read_url.blank?)) do
          options[:read_url] = read_url
        end
      end
      
      def read_url
        Tumblr4Rails.configuration.read_url
      end
      
      def gateway
        @tumblr_gateway ||= Tumblr4Rails::HttpGateway.new
      end
      
      def method_missing(method_name, *args)
        if method_name.to_s =~ /.+_provided?/
          options = args.flatten.first
          thing = method_name.to_s.slice(0...(method_name.to_s.index("_provided?")))
          return options.key?(thing.to_sym) && !options[thing.to_sym].blank?
        else
          super
        end
      end
      
    end
  
  end
  
end
