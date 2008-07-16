module Tumblr4Rails
  
  module WriteOptions
    
    class VideoPostHandler < Tumblr4Rails::WriteOptions::WriteHandler
      
      @@specific_optional_params = [:title, :caption].freeze
      
      @@required_if_upload = [:data].freeze
      
      @@required_if_embed = [:embed].freeze
      
      @@validations = {
        :title => WriteHandler.not_blank_validator,
        :caption => WriteHandler.not_blank_validator,
        :data => WriteHandler.not_blank_validator,
        :embed => WriteHandler.not_blank_validator,
        :type => lambda { |v| v.to_sym == :video }
      }.freeze
      
      def initialize(options)
        super(options)
      end
      
      protected
      
      alias_method :base_ensure_required!, :ensure_required!
      
      def ensure_required!
        check_embed_or_data!
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
        check_embed_or_data!
        if embed_provided?
          @@required_if_embed
        elsif data_provided?
          @@required_if_upload
        end
      end
      
      private
      
      def check_embed_or_data!
        if !embed_provided? && !data_provided?
          raise ArgumentError.new("Either data or embed parameters are required.")
        end
      end
      
    end
    
  end
  
end
