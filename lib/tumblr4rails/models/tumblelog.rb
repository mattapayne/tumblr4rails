module Tumblr4Rails

  class Tumblelog
    
    include Tumblr4Rails::ModelMethods
    
    attr_reader :feeds, :name, :timezone, :title
    
    private
    
    def after_initialized(attributes)
      @readonly = true
      return if attributes.blank?
      @feeds = attributes[:feeds].inject([]) {|arr, f| 
        arr << Tumblr4Rails::Feed.new(f); arr } if has?(:feeds, attributes)
    end
    
  end
end