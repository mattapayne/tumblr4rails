module Tumblr4Rails
  
  module WriteOptions
    
    class PhotoPostHandler < Tumblr4Rails::WriteOptions::WriteHandler
      
      @@specific_optional_params = [:caption, :"click-through-url"].freeze
      
      @@required_if_upload = [:data].freeze
      
      @@required_if_source = [:source].freeze
      
      @@validations = {
        :caption => WriteHandler.not_blank_validator,
        :"click-through-url" => WriteHandler.url_validator,
        :source => WriteHandler.url_validator,
        :data => WriteHandler.not_blank_validator,
        :type => lambda { |v| v.to_sym == :photo }
      }.freeze
      
      def initialize(options)
        super(options)
      end
      
      protected
      
      alias_method :base_ensure_required!, :ensure_required!
      
      def ensure_required!
        check_source_or_data!
        if data_provided? && options[:data].filename.blank?
          raise ArgumentError.new("You must provide the filename when uploading a file.")
        end
        base_ensure_required!
      end
      
      def post_specific_optional_params
        @@specific_optional_params
      end
      
      def post_specific_validations
        @@validations
      end
      
      def post_specific_required_params
        check_source_or_data!
        if source_provided?
          @@required_if_source
        elsif data_provided?
          @@required_if_upload
        end
      end
      
      private
      
      def check_source_or_data!
        if !source_provided? && !data_provided?
          raise ArgumentError.new("Either data or source parameters are required.")
        end
      end
      
    end
    
  end
  
end
