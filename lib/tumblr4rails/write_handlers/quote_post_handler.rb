module Tumblr4Rails
  
  module WriteOptions
    
    class QuotePostHandler < Tumblr4Rails::WriteOptions::WriteHandler
      
      @@specific_required_params = [:quote].freeze
      
      @@specific_optional_params = [:source].freeze
      
      @@validations = {
        :quote => WriteHandler.not_blank_validator,
        :source => WriteHandler.not_blank_validator,
        :type => lambda { |v| v.to_sym == :quote }
      }.freeze
      
      def initialize(options)
        super(options)
      end
      
      protected
      
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
