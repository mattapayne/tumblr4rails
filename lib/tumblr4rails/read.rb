module Tumblr4Rails
  
  module Read
    
    @@read_methods = [ [:all_posts, :all], [:regular_posts, :regular], 
      [:photo_posts, :photo], [:quote_posts, :quote], [:link_posts, :link], 
      [:conversation_posts, :conversation], [:audio_posts, :audio], 
      [:video_posts, :video] ].freeze
      
    def self.included(klazz)
      klazz.send(:include, ReadMethods)
      add_dynamic_finders(klazz)
    end
    
    def self.extended(klazz)
      klazz.extend(ReadMethods)
      add_dynamic_finders(klazz.class)
    end
    
    private
      
    def self.add_dynamic_finders(klazz)
      @@read_methods.each do |tup|
        klazz.class_eval(%{
              def #{tup.first}(options={})
                options = options.merge(:type => :#{tup.last})
                posts(options)
              end
          })
      end
    end
      
    module ReadMethods
      include Tumblr4Rails::Converter
      include Tumblr4Rails::ReadWriteCommon
      
      @@exclude_params_if_id = [:start, :num, :type].freeze
      @@params_to_remove_before_read = [:json, :read_url].freeze
      @@default_read_params =  {:start => nil, :num => nil, :type => nil, 
        :id => nil, :json => false, :read_url => nil, :callback => nil}.freeze
      @@read_param_aliases = {:limit => :num, :index => :start}.freeze
      @@allowed_tumblr_numbers = 1..50
      
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
        options = options.symbolize_keys
        json = extract_json!(options)
        cleanup_read_params!(options, json)
        response = get_response(options, json)
        return response.body if json
        return convert(response.body)
      end
      
      private
      
      def get_response(options, json)
        return gateway.get_posts(generate_read_url(options, json))
      end
      
      #The XXX_provided? methods are handled by a method_missing in common.rb
      def cleanup_read_params!(options, json)
        translate_read_param_aliases!(options)
        merge_params_with_default_params!(options)
        remove_blank_and_invalid_read_params!(options)
        remove_callback!(options) if (callback_provided?(options) && !json)
        remove_unecessary_read_params!(options) if id_provided?(options)
        ensure_post_type!(options) unless id_provided?(options)
        ensure_number!(options) if num_provided?(options)
        ensure_read_url!(options) unless read_url_provided?(options)
      end
      
      def remove_callback!(options)
        options.delete(:callback)
      end
      
      def extract_json!(options)
        options.delete(:json) || false
      end
      
      def remove_blank_and_invalid_read_params!(options)
        options.delete_if {|k, v| (v.blank? || !default_read_params.include?(k)) }
      end
      
      def translate_read_param_aliases!(options)
        read_param_aliases.keys.each do |k|
          options[read_param_aliases[k]] = options.delete(k) if options.key?(k)
        end
      end
      
      def merge_params_with_default_params!(options)
        options.reverse_merge!(default_read_params)
      end
      
      def remove_unecessary_read_params!(options)
        options.delete_if {|k, v| exclude_read_params_if_id.include?(k) }
      end
      
      def ensure_number!(options)
        return unless num_provided?(options)
        options[:num] = read_number_range.max if options[:num].to_i > read_number_range.max
        options[:num] = read_number_range.min if options[:num].to_i < read_number_range.min
      end
      
      def ensure_post_type!(options)
        return unless type_provided?(options)
        unless post_types.include?(options[:type].to_sym)
          raise ArgumentError.new("You must supply a type of: #{post_types.inspect}")
        end
        options.delete_if {|k,v| (k == :type && (v == :all || v == "all"))}
      end
      
      def generate_read_url(options, json)
        url = "#{options[:read_url]}#{json ? '/json' : ''}"
        options.delete_if {|k, v| (params_to_remove_before_read.include?(k) || v.blank?) }
        url += "?#{options.to_param}" unless options.blank?
        url
      end
      
      def ensure_read_url!(options)
        raise ArgumentError.new("Could not determine Tumblr read url") unless read_url
        options[:read_url] = read_url
      end
      
      def read_number_range
        @@allowed_tumblr_numbers
      end
      
      def read_param_aliases
        @@read_param_aliases
      end
      
      def default_read_params
        @@default_read_params
      end
      
      def params_to_remove_before_read
        @@params_to_remove_before_read
      end
      
      def exclude_read_params_if_id
        @@exclude_params_if_id
      end
      
      def read_url
        if request_type == RequestType.application
          Tumblr4Rails.configuration.read_url
        end
      end
      
    end
  
  end
  
end
