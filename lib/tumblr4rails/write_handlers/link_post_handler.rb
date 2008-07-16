module Tumblr4Rails
  
  module WriteOptions
    
    class LinkPostHandler < Tumblr4Rails::WriteOptions::WriteHandler
      
      @@specific_required_params = [:url].freeze
      
      @@specific_optional_params = [:name, :description].freeze
      
      @@validations = {
        :url => WriteHandler.url_validator,
        :name => WriteHandler.not_blank_validator,
        :description => WriteHandler.not_blank_validator,
        :type => lambda { |v| v.to_sym == :link }
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
