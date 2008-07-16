module Tumblr4Rails
  
  class PostType
  
    attr_reader :name
    private_class_method(:new)
    
    @@post_types = [:all, :audio, :conversation, :link, :photo, :quote, :regular, :video ].freeze
    
    def initialize(name)
      @name = name
    end
    
    @@post_types.each do |t|
      self.class_eval("def self.#{t}; new(:#{t}); end;")
    end
  
    def self.all_post_types
      @@all ||= [self.all, self.audio, self.conversation, self.link, 
        self.photo, self.quote, self.regular, self.video]
    end
  
    def self.post_type_names
      @@names ||= self.all_post_types.inject([]) {|arr, type| 
        arr << type.name; arr << type.name.to_s; arr;}
    end
  
    def to_s
      @name.to_s
    end
  
  end
  
end
