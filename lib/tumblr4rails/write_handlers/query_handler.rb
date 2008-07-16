module Tumblr4Rails
  
  module WriteOptions
    
    class QueryHandler
      
      @@required_params = [:email, :password, :action, :write_url].freeze
      @@available_queries = [:authenticate, "check-vimeo", "check-audio" ].freeze
      
      @@validations = {
        :action => lambda {|v| !v.blank? && @@available_queries.include?(v)},
        :write_url => lambda {|v| (v =~ URI.regexp) != nil}
      }.freeze
      
      def initialize(options)
        @options = options.dup unless options.blank?
      end
      
      def process!
        cleanse!
        ensure_required!
        validate_values!
        return options
      end
      
      protected
      
      def validate_values!
        failures = []
        options.each do |param, value|
          if validation = validations[param]
            failures << "The value for #{param} is invalid." unless validation.call(value)
          end
        end
        raise ArgumentError.new(failures.to_sentence) unless failures.empty?
      end
      
      def ensure_required!
        errors = []
        required_params.each do |required|
          errors << "#{required} is a required." unless options.key?(required)
          errors << "#{required} must have a value." if options[required].blank?
        end
        raise ArgumentError.new(errors.to_sentence) unless errors.blank?
      end
      
      def cleanse!
        options.reject! {|k, v| v.blank? || !required_params.include?(k)}
      end
      
      def options
        @options
      end
      
      def validations
        @@validations
      end
      
      def required_params
        @@required_params
      end
      
    end
    
  end
end
