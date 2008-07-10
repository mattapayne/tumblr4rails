module Tumblr4Rails

  class Tumblelog
    
    include Tumblr4Rails::ModelMethods
    
    attr_reader :feeds, :name, :timezone, :title
    
    private
    
    def readonly?
      true
    end
    
    def after_initialized(attributes)
      @feeds = []
      @feeds = attributes[:feeds].inject([]) {|arr, f| 
        arr << Tumblr4Rails::Feed.new(f); arr } if has?(:feeds, attributes)
      @feeds.freeze
    end
    
  end
end