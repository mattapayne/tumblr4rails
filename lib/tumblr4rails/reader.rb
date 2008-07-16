module Tumblr4Rails
  
  class Reader
    extend Tumblr4Rails::PseudoDbc
    
    @@read_methods = [ [:all_posts, :all], [:regular_posts, :regular], 
      [:photo_posts, :photo], [:quote_posts, :quote], [:link_posts, :link], 
      [:conversation_posts, :conversation], [:audio_posts, :audio], 
      [:video_posts, :video] ].freeze
    
    class << self
      @@read_methods.each do |tup|
        class_eval(%{
              def #{tup.first}(options={})
                options = options.merge(:type => :#{tup.last})
                posts(options)
              end
          })
      end
      
    end
      
    def self.get_by_id(id, json=false, callback=nil)
      return if id.blank?
      posts = posts(:id => id, :json => json, :callback => callback)
      return posts if (json || posts && posts.size > 1)
      return posts.first
    end
      
    #Options:
    #:type => The type of post (:regular, :quote, :photo, :link, :conversation, :video, :audio)
    #:limit => The number of posts to return (minimum 1, maximum 50) - alias for num
    #:index => The post offset to start from. - alias for start
    #:start => The post offset to start from
    #:id => The id of the specific post. If this is used, all other params are ignored.
    #:json => if json => true, the response will be a json string
    #:callback => using in conjunction with json => true, specifies a javascript method to
    # execute instead of setting a javascript variable
    def self.posts(options)
      return if options.blank?
      options = cleanup_read_params!(options)
      json = (options.delete(:json) || false)
      response = get_response(options, json)
      return response.body if json
      return Tumblr4Rails::Converter.convert(response.body)
    end
      
    private
      
    def self.get_response(options, json)
      return gateway.get_posts(generate_read_url(options, json))
    end
      
    #The XXX_provided? methods are handled by a method_missing in read_write_common.rb
    def self.cleanup_read_params!(options)
      options = options.symbolize_keys
      ensure_read_url!(options) unless read_url_provided?(options)
      Tumblr4Rails::ReadOptions::ReadHandler.new(options).process!
    end
      
    def self.generate_read_url(options, json)
      url = "#{options.delete(:read_url)}#{json ? '/json' : ''}"
      url += "?#{options.to_param}" unless options.blank?
      url
    end
      
    def self.ensure_read_url!(options)
      pre_ensure("Could not determine Tumblr read_url" => (!read_url.blank?)) do
        options[:read_url] = read_url
      end
    end
      
    def self.read_url
      Tumblr4Rails.configuration.read_url
    end
      
    def self.gateway
      @tumblr_gateway ||= Tumblr4Rails::HttpGateway.new
    end
      
    def self.method_missing(method_name, *args)
      if method_name.to_s =~ /.+_provided?/
        options = args.flatten.first
        thing = method_name.to_s.slice(0...(method_name.to_s.index("_provided?")))
        return options.key?(thing.to_sym) && !options[thing.to_sym].blank?
      else
        super
      end
    end
      
  end
  
end
