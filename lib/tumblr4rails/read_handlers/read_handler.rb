module Tumblr4Rails
  
  module ReadOptions
    
    class ReadHandler
      
      @@aliases = {:limit => :num, :index => :start}.freeze
      @@possible_params = [:id, :type, :num, :start, :limit, :index, :callback, 
        :read_url, :json].freeze
      @@remove_if_id_present = [:num, :start, :type].freeze
      MIN_NUMBER = 1
      MAX_NUMBER = 50
      MIN_START = 0
      
      def initialize(options)
        @options = options.dup unless options.blank?
      end
      
      def process!
        cleanse!
        translate_aliases!
        ensure_number! if num_provided?
        ensure_start! if start_provided?
        return options
      end
      
      protected
      
      def ensure_start!
        if options[:start] && options[:start].to_i < MIN_START
          options[:start] = MIN_START
        end
      end
      
      def ensure_number!
        if options.key?(:num)
          options[:num] = MIN_NUMBER if options[:num].to_i < MIN_NUMBER
          options[:num] = MAX_NUMBER if options[:num].to_i > MAX_NUMBER
        end
      end
      
      def cleanse!
        options.reject! {|k, v| v.blank? || !possible_params.include?(k)}
        if options.key?(:id)
          options.reject! {|k, v| params_to_remove_if_id_present.include?(k)}
        end
        options.delete(:callback) unless options.key?(:json)
        options.reject! {|k, v| (k == :type && v.to_sym == :all)}
      end
      
      def translate_aliases!
        aliases.keys.each do |k|
          options[aliases[k]] = options.delete(k) if options.key?(k)
        end
      end
      
      def options
        @options
      end
      
      private
      
      def aliases
        @@aliases
      end
      
      def possible_params
        @@possible_params
      end
      
      def params_to_remove_if_id_present
        @@remove_if_id_present
      end
      
      def method_missing(method_name, *args)
        if method_name.to_s =~ /.+_provided?/
          thing = method_name.to_s.slice(0...(method_name.to_s.index("_provided?")))
          return options.key?(thing.to_sym) && !options[thing.to_sym].blank?
        else
          super
        end
      end
      
    end
    
  end
  
end
