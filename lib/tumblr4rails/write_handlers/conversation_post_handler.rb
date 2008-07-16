module Tumblr4Rails
  
  module WriteOptions
    
    class ConversationPostHandler < Tumblr4Rails::WriteOptions::WriteHandler
      
      @@specific_required_params = [:conversation].freeze
      
      @@specific_optional_params = [:title].freeze
      
      @@validations = {
        :conversation => WriteHandler.not_blank_validator,
        :title => WriteHandler.not_blank_validator,
        :type => lambda { |v| v.to_sym == :conversation }
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
