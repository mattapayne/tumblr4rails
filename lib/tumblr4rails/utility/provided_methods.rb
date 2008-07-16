module Tumblr4Rails
  
  module ProvidedMethods
  
    def method_missing(method_name, *args)
      if method_name.to_s =~ /.+_provided?/
        thing = method_name.to_s.slice(0...(method_name.to_s.index("_provided?")))
        return options.key?(thing.to_sym) && !options[thing.to_sym].blank?
      else
        super
      end
    end
    
  end
  
end
