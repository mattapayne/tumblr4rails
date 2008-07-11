module Tumblr4Rails
  
  class PostType
  
    attr_reader :name
    private_class_method(:new)
    
    @@post_types = [:all, :audio, :conversation, :link, :photo, :quote, :regular, :video ].freeze
    
    @@post_type_required_params = {
      :regular => [:title, :body],
      :link => [:url],
      :conversation => [:conversation],
      :quote => [:quote]
    }.freeze
    
    @@post_type_optional_params = {
      :photo => [:source, :data, :caption, :"click-through-url", :filename],
      :quote => [:source],
      :link => [:name, :description],
      :conversation => [:title],
      :video => [:embed, :data, :title, :caption, :filename],
      :audio => [:data, :caption, :filename]
    }.freeze
    
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
    
    def self.required_params_for_post(post_type)
      @@post_type_required_params[post_type.to_sym]
    end
    
    def self.optional_params_for_post(post_type)
      @@post_type_optional_params[post_type.to_sym]
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
