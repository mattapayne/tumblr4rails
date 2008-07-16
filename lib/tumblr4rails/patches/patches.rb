#Hack URI::HTTP to include a method that gets us both the path and the querystring
#since path_query is private
module URI
  class HTTP < Generic
    def path_with_querystring
      path_query
    end
  end
end

class Hash
    
  def underscore_keys!
    keys.each do |k|
      value = delete(k)
      value.underscore_keys! if value.is_a?(Hash)
      value.each {|v| v.underscore_keys! if v.is_a?(Hash)} if value.is_a?(Array)
      new_key = k.is_a?(Symbol) ? k.to_s.underscore.to_sym : k.to_s.underscore
      self[new_key] = value
    end
  end
    
end
