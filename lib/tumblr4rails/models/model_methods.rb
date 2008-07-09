module Tumblr4Rails
  
  module ModelMethods
  
    def initialize(attributes={})
      set_readonly(attributes)
      create_accessors
      initialize_attributes(attributes) unless attributes.blank?
      after_initialized(attributes)
    end
    
    def readonly?
      @readonly
    end
    
    private
    
    def set_readonly(attributes)
      @readonly = (attributes.blank? ? false : (attributes.delete(:readonly) || false))
    end
    
    def create_accessors
      accessors = attr_accessors
      readonly = @readonly
      singleton_class.class_eval do
        attr_reader(*accessors) if readonly
        attr_accessor(*accessors) unless readonly
      end
    end
    
    def remove_accessors
      accessors = attr_accessors
      readonly = @readonly
      singleton_class.class_eval do
        accessors.each do |a| 
          remove_method(a)
          unless readonly
            remove_method("#{a}=".to_sym)
          end
        end
      end
    end
    
    def has?(attr, attributes, type=Array)
      return false if attributes.blank?
      attributes.key?(attr) && !attributes[attr].blank? && attributes[attr].is_a?(type)
    end
    
    def singleton_class
      class << self; self; end
    end
    
    def attr_accessors
      []
    end
    
    def attribute_map
      {}
    end
    
    def after_initialized(attributes)
      #Hook
    end
    
    def map_attribute(attr)
      return attr unless attribute_map.key?(attr)
      return attribute_map[attr]
    end
    
    def initialize_attributes(attributes)
      attributes.symbolize_keys!
      attributes.each do |property_name, property_value|
        property_name = map_attribute(property_name)
        if self.respond_to?(property_name)
          self.instance_variable_set("@#{property_name}".to_sym, property_value)
        end
      end
    end
    
  end
  
end
