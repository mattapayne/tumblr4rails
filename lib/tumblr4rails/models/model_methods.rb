module Tumblr4Rails
  
  module ModelMethods
  
    def initialize(attributes={})
      initialize_attributes(attributes) unless attributes.blank?
      after_initialized(attributes)
      if make_readonly?(attributes) || readonly?
        self.freeze
      end
    end
    
    private
    
    def readonly?
      frozen?
    end
    
    def make_readonly?(attributes)
      (attributes.blank? ? false : (attributes.delete(:readonly) || false))
    end
    
    def has?(attr, attributes, type=Array)
      return false if attributes.blank?
      attributes.key?(attr) && !attributes[attr].blank? && attributes[attr].is_a?(type)
    end
    
    def attribute_map
      {}
    end
    
    def after_initialized(attributes)
      #Hook
    end
    
    def map_attribute(attr)
      return attr unless attribute_map && attribute_map.key?(attr)
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
