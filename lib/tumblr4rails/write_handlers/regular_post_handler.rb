module Tumblr4Rails
  
  module WriteOptions
    
    class RegularPostHandler < Tumblr4Rails::WriteOptions::WriteHandler
      
      @@specific_required_params = [:title, :body].freeze
      
      @@validations = {
        :title => WriteHandler.not_blank_validator,
        :body => WriteHandler.not_blank_validator,
        :type => lambda { |v| v.to_sym == :regular }
      }.freeze
      
      def initialize(options)
        super(options)
      end
      
      protected
      
      def post_specific_required_params
        @@specific_required_params
      end
      
      def post_specific_validations
        @@validations
      end
      
    end
  end
end
