module Tumblr4Rails

  class Post
    
    include Tumblr4Rails::ModelMethods, Tumblr4Rails::PseudoDbc
    
    attr_reader :tumblr_id, :post_type, :date_gmt, :date, :unix_timestamp, :url
    
    def self.get(options={})
      Tumblr4Rails::Reader.all_posts(options)
    end
    
    def self.get_by_id(id, json=false, callback=nil)
      Tumblr4Rails::Reader.get_by_id(id, json, callback)
    end
    
    def save(additional_params={})
      begin
        return save!(additional_params).code.to_i == 201
      rescue
        return false
      end
    end
    
    def save!(additional_params={})
      pre_ensure("You cannot save a previously saved model." => (!frozen?)) do
        response = do_save!(additional_params)
        after_save(response)
        response
      end
    end
    
    private
    
    def after_save(response)
      if response.code.to_i == 201
        self.instance_variable_set(:@tumblr_id, response.new_id)
        self.freeze
      end
    end
    
    def do_save!(additional_params={})
      #hook
    end
    
  end

end
