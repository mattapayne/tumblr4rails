module Tumblr4Rails
  
  module Writer
    
    def self.included(klazz)
      klazz.send(:include, WriteMethods)
    end
    
    def self.extended(klazz)
      klazz.extend(WriteMethods)
    end
    
    module WriteMethods
      
      include Tumblr4Rails::PseudoDbc
      include Tumblr4Rails::MissingMethodHandler
      
      #With the exception of the "Other Actions", all write calls return:
      #201 - Created along with the newly created item's id
      #403 - Forbidden if credentials are bad
      #400 - Bad Request if something is wrong with the submitted data. Errors are
      #returned in plain text, 1 per line.
 
      #returns 403 if invalid, 200 if valid
      def authenticated?(options={})
        response = do_query(options.merge(:action => :authenticate))
        response.code.to_i == 200
      end
      
      #Returns 400 wih message and login url if the user is not logged in to Vimeo
      #If the user is logged in, returns 200 and the max bytes that the user can upload.
      def video_upload_permissions(options={})
        response = do_query(options.merge(:action => "check-vimeo"))
        Tumblr4Rails::UploadPermission.new(response.code, response.body)
      end
      
      #returns 400 if the user has exceeded the daily limit, otherwise 200
      def can_upload_audio?(options={})
        response = do_query(options.merge(:action => "check-audio"))
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
        multipart = (options.delete(:multipart) || false)
        options = cleanup_post_params(options)
        r = gateway.post_new_post(options.delete(:write_url), 
          options.merge(:multipart => multipart))
        Tumblr4Rails::Response.new(r.code, r.message, r.body)
      end
      
      #handles the "Other Actions" of the API
      def do_query(options)
        options = options.symbolize_keys
        get_credentials!(options) unless credentials_provided?(options)
        get_write_url!(options) unless write_url_provided?(options)
        options = get_handler(options[:action], options).process!
        gateway.execute_query(options.delete(:write_url), options)
      end
      
      def cleanup_post_params(options)
        options = options.symbolize_keys
        get_credentials!(options) unless credentials_provided?(options)
        get_write_url!(options) unless write_url_provided?(options)
        get_handler(options[:type], options).process!
      end
    
      def get_handler(type, options)
        Tumblr4Rails::WriteOptions::Factory.handler_for(type, options)
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
      
      def write_url
        Tumblr4Rails.configuration.write_url
      end
      
      def email
        Tumblr4Rails.configuration.email
      end
    
      def password
        Tumblr4Rails.configuration.password
      end
      
      def gateway
        @tumblr_gateway ||= Tumblr4Rails::HttpGateway.new
      end
      
    end
    
  end
  
end
