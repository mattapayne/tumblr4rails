module Tumblr4Rails
  
  module WriteOptions
    
    class WriteHandler
      
      MAX_GENERATOR_LENGTH = 64
      DATE_FORMAT = "%m/%d/%Y %I:%M:%S"
      HTML = "html"
      MARKDOWN = "markdown"
      
      @@optional_params = [:generator, :date, :private, :tags, :format, :group].freeze
      @@required_params = [:type, :email, :password, :write_url].freeze
      
      def initialize(options)
        @options = options.dup unless options.blank?
      end
      
      def process!
        cleanse!
        ensure_required!
        convert_values!
        validate_values!
        return options
      end
      
      protected
      
      def self.private_converter
        lambda {|v| return v unless v.is_a?(TrueClass) || v.is_a?(FalseClass)
          return "1" if v.is_a?(TrueClass)
          return "0" if v.is_a?(FalseClass)}
      end
      
      def self.date_converter
        lambda { |date| date.strftime(DATE_FORMAT)}
      end
      
      def self.format_converter
        lambda { |f| return f.to_s.downcase if f; return nil}
      end
      
      def self.format_validator
        lambda {|v| !v.blank? && (v.to_s.downcase == HTML || 
              v.to_s.downcase == MARKDOWN)}
      end
      
      def self.private_validator
        lambda { |v| !v.blank? && (v.to_s == "1" || v.to_s == "0")}
      end
      
      def self.group_validator
        lambda {|v| !v.blank? && ((v.to_s =~ URI.regexp) != nil || 
              (v.to_s =~ /^.+\d$/) != nil)}
      end
      
      def self.not_blank_validator
        lambda {|v| !v.blank?}
      end
      
      def self.url_validator
        lambda { |v| (v.to_s =~ URI.regexp) != nil}
      end
      
      def self.generator_validator
        lambda { |v| !v.blank? && v.to_s.length <= MAX_GENERATOR_LENGTH }
      end
      
      def self.email_validator
        lambda {|v| !v.blank? && ((v.to_s =~ RFC822::EmailAddress) != nil)}
      end
      
      @@base_validations = {
        :generator => self.generator_validator,
        :date => self.not_blank_validator,
        :private => self.private_validator,
        :tags => self.not_blank_validator,
        :group => self.group_validator,
        :format => self.format_validator,
        :email => self.email_validator,
        :password => self.not_blank_validator,
        :write_url => self.url_validator
      }.freeze
      
      @@conversions = {
        :date => self.date_converter,
        :private => self.private_converter,
        :format => self.format_converter
      }.freeze
      
      #Convert any values that need to be converted into some other form
      #ie: A date => String
      def convert_values!
        options.each do |key, value|
          if converter = all_conversions[key]
            options[key] = converter.call(value)
          end 
        end
      end
      
      #Ensure that, at a bare minimum, we have the required parameters for the post type
      def ensure_required!
        errors = []
        all_required_params.each do |required|
          errors << "#{required} is a required parameter" unless options.key?(required)
          errors << "#{required} must have a value" if options[required].blank?
        end
        raise ArgumentError.new(errors.to_sentence) unless errors.blank?
      end
      
      #Ensure that the values provided are acceptable
      def validate_values!
        failures = []
        options.each do |param, value|
          if validation = all_validations[param]
            failures << "Invalid value: #{value} for: #{param}" unless validation.call(value)
          end
        end
        raise ArgumentError.new(failures.to_sentence) unless failures.blank?
      end
      
      def cleanse!
        options.reject! do |k ,v| 
          v.blank? || !all_params.include?(k)
        end
      end
      
      def common_required_params
        @@required_params
      end
      
      def common_optional_params
        @@optional_params
      end
      
      def post_specific_optional_params
        []
      end
      
      def post_specific_required_params
        []
      end
      
      def post_specific_conversions
        {}
      end
      
      def post_specific_validations
        {}
      end
      
      def options
        @options
      end
      
      private
      
      def all_conversions
        @convs ||= @@conversions.merge(post_specific_conversions)
      end
      
      def all_validations
        @vals ||= @@base_validations.merge(post_specific_validations)
      end
      
      def all_params
        @all ||= (all_required_params + all_optional_params).uniq
      end
      
      def all_optional_params
        @all_opt ||= (common_optional_params + post_specific_optional_params).uniq
      end
      
      def all_required_params
        @all_req ||= (common_required_params + post_specific_required_params).uniq
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
