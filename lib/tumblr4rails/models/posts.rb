module Tumblr4Rails
  
  class Posts < Array
    
    include Tumblr4Rails::ModelMethods
    
    attr_reader :start, :total, :post_type, :tumblelog
    
    private
    
    def after_initialized(attributes)
      return if attributes.blank?
      @tumblelog = Tumblr4Rails::Tumblelog.new(attributes[:tumblelog]) if has?(:tumblelog, attributes, Hash)
      attributes[:posts].each {|p| 
        self << Tumblr4Rails::PostFactory.create_post(p)} if has?(:posts, attributes)
    end

  end
  
end
