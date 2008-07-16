module Tumblr4Rails
  
  module WriteOptions
    
    class AudioPostHandler < Tumblr4Rails::WriteOptions::WriteHandler
      
      @@specific_required_params = [:data].freeze
      
      @@specific_optional_params = [:caption].freeze
      
      @@validations = {
        :data => WriteHandler.not_blank_validator,
        :caption => WriteHandler.not_blank_validator,
        :type => lambda { |v| v.to_sym == :audio }
      }.freeze
      
      def initialize(options)
        super(options)
      end
      
      protected
      
      alias_method :base_ensure_required!, :ensure_required!
      
      def ensure_required!
        if data_provided? && options[:data].filename.blank?
          raise ArgumentError.new("You must provide the filename when uploading a file.")
        end
        base_ensure_required!
      end
      
      def post_specific_optional_params
        @@specific_optional_params
      end
      
      def post_specific_required_params
        @@specific_required_params
      end
      
      def post_specific_validations
        @@validations
      end
      
    end
    
  end
  
end
