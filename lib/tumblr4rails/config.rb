module Tumblr4Rails
  
  class Config   
    
    attr_accessor :password, :email, :request_type, :write_url, :read_url, :upload_mime_types
    
    DEFAULT_WRITE_URL = "http://www.tumblr.com/api/write"
    
    def initialize
      self.request_type = Tumblr4Rails::RequestType.request
      self.write_url = DEFAULT_WRITE_URL
      self.upload_mime_types = {}
    end
    
    def errors
      return no_request_type_error unless request_type_valid?
      return (validators[self.request_type.to_sym].call() || []).compact
    end
    
    def valid?
      errors.size == 0
    end
    
    private
    
    def no_request_type_error
      ["You must set request type to one of: #{Tumblr4Rails::RequestType.all.inspect}."]
    end
    
    def validators
      {
        Tumblr4Rails::RequestType.request => lambda { 
          validate(Tumblr4Rails::RequestType.request, true) },
        Tumblr4Rails::RequestType.application => lambda { 
          validate(Tumblr4Rails::RequestType.application, false) }
      }
    end
    
    def request_type_valid?
      !self.request_type.blank? && 
        Tumblr4Rails::RequestType.all.include?(self.request_type.to_sym)
    end
    
    def validate(request_type, ensure_blank)
      errors = []
      [:read_url, :password, :email].each do |prop|
        errors << ensure_property(prop, request_type , ensure_blank)
      end
      if request_type == Tumblr4Rails::RequestType.application
        errors << ensure_property(:write_url, request_type , ensure_blank)
      end
      errors
    end
    
    def ensure_property(property_name, request_type, ensure_blank=false)
      property_name = property_name.to_sym unless property_name.is_a?(Symbol)
      value = self.send(property_name)
      if should_be_blank_but_is_not(ensure_blank, value)
        return "You cannot set #{property_name} when the request type is #{request_type}."
      elsif should_not_be_blank_but_is(ensure_blank, value)
        return "You must set #{property_name} when request type is #{request_type}."
      end
      return nil
    end
    
    def should_be_blank_but_is_not(blank, value)
      blank && !value.blank?
    end
    
    def should_not_be_blank_but_is(blank, value)
      !blank && value.blank?
    end

  end
  
end