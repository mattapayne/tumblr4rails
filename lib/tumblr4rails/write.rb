module Tumblr4Rails
  
  module Write
    
    def self.included(klazz)
      klazz.send(:include, WriteMethods)
    end
    
    def self.extended(klazz)
      klazz.extend(WriteMethods)
    end
    
    #With the exception of the "Other Actions", all write calls return:
    #201 - Created along with the newly created item's id
    #403 - Forbidden if credentials are bad
    #400 - Bad Request if something is wrong with the submitted data. Errors are
    #returned in plain text, 1 per line.
    module WriteMethods
      
      include Tumblr4Rails::ReadWriteCommon, Tumblr4Rails::PseudoDbc
      
      MAX_GENERATOR_LENGTH = 64
      DATE_FORMAT = "%m/%d/%Y %I:%M:%S"
      HTML = "html"
      MARKDOWN = "markdown"
      @@optional_write_params = [:generator, :date, :private, :tags, :format, :group].freeze
      @@required_write_params = [:email, :password, :write_url, :type]
      @@write_param_conversions = {
        :date => lambda { |date| date.strftime(DATE_FORMAT)},
        :private => lambda {|value|
          return value unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
          return "1" if value.is_a?(TrueClass)
          return "0" if value.is_a?(FalseClass)
        }
      }.freeze
      @@valid_do_write_action_params = [:email, :password, :action, :write_url].freeze
      @@write_param_validations = {
        :email => lambda { |email| (email =~ RFC822::EmailAddress) != nil },
        :type => lambda { |type| Tumblr4Rails::PostType.post_type_names.include?(type) },
        :generator => lambda { |gen| gen.length <= MAX_GENERATOR_LENGTH },
        :private => lambda { |private| ((private.to_s == "1" || 
                private.to_s == "0")) || (private.is_a?(TrueClass) || private.is_a?(FalseClass))},
        :format => lambda { |format| (format.to_s.downcase == HTML || 
              format.to_s.downcase == MARKDOWN)},
        :group => lambda { |group| ((group =~ URI.regexp) != nil) || ((group =~ /^\.*d$/) != nil)},
        :source => lambda { |src| (src =~ URI.regexp) != nil},
        :"click-through-url" => lambda { |ctu| (ctu =~ URI.regexp) != nil },
        :url => lambda { |url| (url =~ URI.regexp) != nil },
        :read_url => lambda { |url| (url =~ URI.regexp) != nil },
        :write_url => lambda { |url| (url =~ URI.regexp) != nil }
      }.freeze
      
      @@valid_write_params = [:email, :password, :type, :data, :embed, :source,
        :url, :conversation, :title, :body, :name, :description, :generator, 
        :date, :private, :tags, :format, :group, :caption, :quote, 
        :"click-through-url"].freeze
      
      #returns 403 if invalid, 200 if valid
      def authenticated?(options={})
        response = do_write_action(options.merge(:action => :authenticate))
        response.code.to_i == 200
      end
      
      #Returns 400 wih message and login url if the user is not logged in to Vimeo
      #If the user is logged in, returns 200 and the max bytes that the user can upload.
      def video_upload_permissions(options={})
        response = do_write_action(options.merge(:action => "check-vimeo"))
        Tumblr4Rails::UploadPermission.new(response.code, response.body)
      end
      
      #returns 400 if the user has exceeded the daily limit, otherwise 200
      def can_upload_audio?(options={})
        response = do_write_action(options.merge(:action => "check-audio"))
        response.code.to_i == 200
      end
      
      def create_regular_post(title, body, additional_options={})
        create_post({:type => :regular, :title => title, 
            :body => body}.reverse_merge(additional_options))
      end
      
      def create_link_post(url, name=nil, description=nil, additional_options={})
        create_post({:type => :link, :url => url, 
            :name => name, :description => description}.reverse_merge(additional_options))
      end
      
      def create_photo_post(src, caption=nil, click_through_url=nil, additional_options={})
        pre_ensure("The src param is required." => (!src.blank?)) do
          common_args = {
            :type => :photo, :"click-through-url" => click_through_url,
            :caption => caption
          }.reverse_merge!(additional_options)
          if src.is_a?(Tumblr4Rails::Upload)
            common_args.merge!(:data => src, :multipart => true)
          else
            common_args.merge!(:source => src)
          end
          create_post(common_args)
        end
      end
      
      def create_audio_post(src, caption=nil, additional_options={})
        pre_ensure("The src param is required" => (!src.blank?)) do
          pre_ensure("The data param must be an instance of Tumblr4Rails::Upload" => 
              (src.is_a?(Tumblr4Rails::Upload))) do
            create_post({:type => :audio, :data => src, :caption => caption, 
                :multipart => true}.reverse_merge(additional_options))
          end
        end
      end
      
      def create_video_post(src, title=nil, caption=nil, additional_options={})
        pre_ensure("The src param is required" => (!src.blank?)) do
          common_args = {
            :type => :video, :title => title, 
            :caption => caption}.reverse_merge!(additional_options)
          if src.is_a?(Tumblr4Rails::Upload)
            common_args.merge!(:data => src, :multipart => true)
          else
            common_args.merge!(:embed => src)
          end
          create_post(common_args)
        end
      end
      
      #Note that the conversation should be separated by newlines
      #ie: "Me: Hi, how are you?\nYou: I am fine, thanks"
      #This will ensure that it appears properly in the Tumblr UI.
      def create_conversation_post(conversation, title=nil, additional_options={})
        create_post({:type => :conversation, :conversation => conversation, 
            :title => title}.reverse_merge(additional_options))
      end
      
      def create_quote_post(quote, source=nil, additional_options={})
        create_post({:type => :quote, :quote => quote, 
            :source => source}.reverse_merge(additional_options))
      end
      
      private
      
      def create_post(options)
        raise ArgumentError.new("Post creation options cannot be blank.") if options.blank?
        post_options = options.split_on!(:multipart)
        options = cleanup_write_params(options)
        r = gateway.post_new_post(options.delete(:write_url), options.merge(post_options))
        Tumblr4Rails::PostCreationResponse.new(r.code, r.message, r.body)
      end
      
      def ensure_necessary_write_params_present!(options)
        errors = []
        errors << "The post type must be supplied." unless type_provided_and_valid?(options)
        errors << "Proper credentials are required." unless credentials_provided?(options)
        if type_provided?(options)
          required = required_write_params_for_post(options[:type])
          unless required.blank?
            required.each do |param|
              unless options.key?(param) && !options[param].blank?
                errors << "#{param} is required to create a #{options[:type].to_s.humanize} post."
              end
            end
          end
        end
        raise ArgumentError.new("Could not create post:\n #{errors.to_sentence}") unless errors.empty?
      end
      
      def cleanup_write_params(options)
        options = options.symbolize_keys
        get_credentials!(options) unless credentials_provided?(options)
        get_write_url!(options) unless write_url_provided?(options)
        remove_blank_or_invalid_write_params!(options)
        ensure_necessary_write_params_present!(options)
        convert_write_param_values!(options)
        ensure_write_param_values_pass_validation!(options)
      end
      
      def get_credentials!(options)
        options.merge!(:email => extract_email, :password => extract_password)
      end
      
      def get_write_url!(options)
        options.merge!(:write_url => extract_write_url)
      end
      
      def credentials_provided?(options)
        email_provided?(options) && password_provided?(options)
      end
      
      def type_provided_and_valid?(options)
        type_provided?(options) && post_types.include?(options[:type])
      end
      
      def ensure_write_param_values_pass_validation!(options)
        options.each do |key, value|
          if write_param_validations.key?(key)
            unless write_param_validations[key].call(value)
              raise ArgumentError.new("Invalid value '#{value}' for param #{key.to_s.humanize}.")
            end
          end
        end
      end
      
      def remove_blank_or_invalid_write_params!(options)
        possible = all_possible_write_params_for_post(options[:type])
        options.delete_if {|k,v| !possible.include?(k) || v.blank?}
      end
      
      def convert_write_param_values!(options)
        write_param_conversions.each do |param, proc|
          options[param] = proc.call(options[param]) if options.key?(param)
        end
      end
      
      #handles the "Other Actions" of the API
      def do_write_action(options)
        options.symbolize_keys!
        get_credentials!(options) unless credentials_provided?(options)
        get_write_url!(options) unless write_url_provided?(options)
        remove_invalid_or_blank_do_write_action_params!(options)
        get_do_write_action_response(options)
      end
      
      def get_do_write_action_response(options)
        gateway.execute_query(options.delete(:write_url), options)
      end
      
      def remove_invalid_or_blank_do_write_action_params!(options)
        options.delete_if { |k,v| !valid_do_write_action_params.include?(k) || v.blank?}
      end
      
      def extract_email
        pre_ensure("Cannot determine Tumblr email" => (!email.blank?)) do
          return email
        end
      end
      
      def extract_password
        pre_ensure("Cannot determine Tumblr password" => (!password.blank?)) do
          return password
        end
      end
      
      def extract_write_url
        pre_ensure("Cannot determine Tumblr write url" => (!write_url.blank?)) do
          return write_url
        end
      end
      
      def write_param_validations
        @@write_param_validations
      end
      
      def write_param_conversions
        @@write_param_conversions
      end
      
      def valid_write_params
        @@valid_write_params
      end
      
      def optional_write_params
        @@optional_write_params
      end
      
      def valid_do_write_action_params
        @@valid_do_write_action_params
      end
      
      def required_write_params_for_post(post_type)
        Tumblr4Rails::PostType.required_params_for_post(post_type)
      end
      
      def all_possible_write_params_for_post(post_type)
        (Tumblr4Rails::PostType.required_params_for_post(post_type) || []) +
          (Tumblr4Rails::PostType.optional_params_for_post(post_type) || []) +
          @@optional_write_params + @@required_write_params
      end
      
      def write_url
        Tumblr4Rails.configuration.write_url
      end
      
      def email
        if request_type == RequestType.application
          Tumblr4Rails.configuration.email
        end
      end
    
      def password
        if request_type == RequestType.application
          Tumblr4Rails.configuration.password
        end
      end
      
    end
    
  end
  
end
