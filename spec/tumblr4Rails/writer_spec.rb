require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::Writer do
  
  before(:each) do
    @gateway = mock("Gateway")
    Tumblr4Rails::Writer.stub!(:gateway).and_return(@gateway)
  end
  
  describe "queries" do
  
    describe "can_upload_audio?" do
    
      before(:each) do
        @resp = create_mock_audio_response
        @gateway.stub!(:execute_query).and_return(@resp)
      end
    
      it "should merge in :action => 'check-audio'" do
        mock_hash = create_do_write_action_hash
        mock_hash.should_receive(:merge).with(:action => "check-audio")
        Tumblr4Rails::Writer.stub!(:do_query).and_return(@resp)
        Tumblr4Rails::Writer.can_upload_audio?(mock_hash)
      end
    
      it "should return true if the response code is 200" do
        Tumblr4Rails::Writer.can_upload_audio?(:email => "test@test.ca", :password => "dfsdf").should be_true
      end
    
      it "should return false if the response code is not 200" do
        @resp.stub!(:code).and_return("400")
        Tumblr4Rails::Writer.can_upload_audio?(:email => "test@test.ca", :password => "dfsdf").should be_false
      end
    
    end
  
    describe "video_upload_permissions" do
    
      before(:each) do
        @resp = create_mock_video_response
        @gateway.stub!(:execute_query).and_return(@resp)
      end
    
      it "should merge in :action => 'check-vimeo'" do
        mock_hash = create_do_write_action_hash
        mock_hash.should_receive(:merge).with(:action => "check-vimeo")
        Tumblr4Rails::Writer.stub!(:do_query).and_return(@resp)
        Tumblr4Rails::Writer.video_upload_permissions(mock_hash)
      end
    
      it "should return an instance of Tumblr4Rails::UploadPermission" do
        resp = Tumblr4Rails::Writer.video_upload_permissions(:email => "test@test.ca", :password => "sdsddff")
        resp.should be_is_a(Tumblr4Rails::UploadPermission)
      end
    
    end
    
    describe "authenticated? in general" do
    
      before(:each) do
        @resp = create_mock_authenticated_response
        @gateway.stub!(:execute_query).and_return(@resp)
      end
    
      it "it should merge in :action => :authenticate" do
        mock_hash = create_do_write_action_hash
        mock_hash.should_receive(:merge).with(:action => :authenticate)
        Tumblr4Rails::Writer.stub!(:do_query).and_return(@resp)
        Tumblr4Rails::Writer.authenticated?(mock_hash)
      end
    
      it "should return true if the response code is 200" do
        Tumblr4Rails::Writer.authenticated?({:email => "test@test.ca", :password => "xxx"}).should be_true
      end
    
      it "should return false if the response code is not 200" do
        @resp.stub!(:code).and_return("400")
        Tumblr4Rails::Writer.authenticated?({:email => "test@test.ca", :password => "xxx"}).should be_false
      end
    
    end
  
    describe "authenticated? with request_type == :request" do

      before(:each) do
        configure_tumblr_for_request_requests
        @resp = create_mock_authenticated_response
        @gateway.stub!(:execute_query).and_return(@resp)
      end
    
      it "should be authenticated if the email and password are provided" do
        Tumblr4Rails::Writer.authenticated?({:password => "xxx", :email => "test@test.ca"}).should be_true
      end
    
      it "should raise an exception if the email is not passed in" do
        lambda {
          Tumblr4Rails::Writer.authenticated?({:password => "xxx"}).should be_false
        }.should raise_error
      end
    
      it "should raise an exception if the email passed in is blank" do
        lambda {
          Tumblr4Rails::Writer.authenticated?({:email => nil, :password => "xxx"}).should be_false
        }.should raise_error
      end
    
      it "should raise an exception if the passowrd is not passed in" do
        lambda {
          Tumblr4Rails::Writer.authenticated?({:email => "test@test.ca"}).should be_false
        }.should raise_error
      end
    
      it "should raise an exception if the password passed in is blank" do
        lambda {
          Tumblr4Rails::Writer.authenticated?({:email => "test@test.ca", :password => nil}).should be_false
        }.should raise_error
      end
    
    end
  
    describe "authenticated? with request_type == :application" do
    
      before(:each) do
        configure_tumblr_for_application_requests
        @resp = create_mock_authenticated_response
        @gateway.stub!(:execute_query).and_return(@resp)
      end
    
      it "should be authenticated if email and password are set" do
        Tumblr4Rails::Writer.authenticated?.should be_true
      end
   
      it "should raise an exception if the email is nil" do
        Tumblr4Rails::Writer.stub!(:email).and_return(nil)
        lambda{
          Tumblr4Rails::Writer.authenticated?
        }.should raise_error
      end
    
      it "should raise an exception if the email is blank" do
        Tumblr4Rails::Writer.stub!(:email).and_return("")
        lambda {
          Tumblr4Rails::Writer.authenticated?
        }.should raise_error
      end
    
      it "should raise an exception if the password is nil" do
        Tumblr4Rails::Writer.stub!(:password).and_return(nil)
        lambda{
          Tumblr4Rails::Writer.authenticated?
        }.should raise_error
      end
    
      it "should raise an exception if the password is blank" do
        Tumblr4Rails::Writer.stub!(:password).and_return("")
        lambda {
          Tumblr4Rails::Writer.authenticated?
        }.should raise_error
      end
    
    end
  
  end
  
  describe "create posts" do
    
    before(:each) do
      @resp = create_mock_write_response
      @gateway.stub!(:post_new_post).and_return(@resp)
    end
      
    describe "create regular post" do
    
      it "should receive args with the proper contents" do
        Tumblr4Rails::Writer.should_receive(:create_post).with(
          hash_including(:type => :regular, :title => "Title", :body => "Body"))
        Tumblr4Rails::Writer.create_regular_post("Title", "Body")
      end
    
      it "should receive args with additional arguments included" do
        Tumblr4Rails::Writer.should_receive(:create_post).with(
          hash_including(:generator => "Test", :private => "1"))
        Tumblr4Rails::Writer.create_regular_post("Title", "Body", {:generator => "Test", :private => "1"})
      end
    
    end
  
    describe "create link post" do
    
      it "should receive args with the proper contents" do
        Tumblr4Rails::Writer.should_receive(:create_post).with(
          hash_including(:type => :link, :url => "http://www.google.ca")
        ).and_return(@resp)
        Tumblr4Rails::Writer.create_link_post("http://www.google.ca")
      end
    
      it "should receive args with additional arguments included" do
        Tumblr4Rails::Writer.should_receive(:create_post).with(
          hash_including(:generator => "Test", :private => "0", :name => "Google",
            :description => "A Search Engine")
        ).and_return(@resp)
        Tumblr4Rails::Writer.create_link_post("http://www.google.ca", 
          "Google", "A Search Engine", {:generator => "Test", :private => "0"})
      end
    
    end
  
    describe "create conversation post" do
    
      it "should receive args with the proper contents" do
        Tumblr4Rails::Writer.should_receive(:create_post).with(
          hash_including(:type => :conversation, :conversation => "blah")
        ).and_return(@resp)
        Tumblr4Rails::Writer.create_conversation_post("blah", nil)
      end
    
      it "should receive args with additional arguments included" do
        Tumblr4Rails::Writer.should_receive(:create_post).with(
          hash_including(:generator => "Test", :private => "0", :conversation => "blah")
        ).and_return(@resp)
        Tumblr4Rails::Writer.create_conversation_post("blah", nil, {:generator => "Test", :private => "0"})
      end
    
    end
  
    describe "create quote post" do
    
      it "should receive args with the proper contents" do
        Tumblr4Rails::Writer.should_receive(:create_post).with(
          hash_including(:type => :quote, :quote => "a quote")
        ).and_return(@resp)
        Tumblr4Rails::Writer.create_quote_post("a quote")
      end
    
      it "should receive args with additional arguments included" do
        Tumblr4Rails::Writer.should_receive(:create_post).with(
          hash_including(:generator => "Test", :private => "0", :quote => "a quote", :source => "A Source")
        ).and_return(@resp)
        Tumblr4Rails::Writer.create_quote_post("a quote", "A Source", {:generator => "Test", :private => "0"})
      end
    
    end
  
    describe "create audio post" do
    
      before(:each) do
        @data = Tumblr4Rails::Upload.new("file.xml", "text/xml", "some data")
      end
    
      it "should receive args with the proper contents" do
        Tumblr4Rails::Writer.should_receive(:create_post).with(
          hash_including(:type => :audio, :data => @data, 
            :multipart => true)).and_return(@resp)
        Tumblr4Rails::Writer.create_audio_post(@data)
      end
    
      it "should receive args with additional arguments included" do
        Tumblr4Rails::Writer.should_receive(:create_post).with(
          hash_including(:generator => "Test", :private => "0", :multipart => true,
            :caption => "A Song", :data => @data)).and_return(@resp)
        Tumblr4Rails::Writer.create_audio_post(@data, "A Song", {:generator => "Test", :private => "0"})
      end
    
      it "should raise an error if the data parameter is not an instance of Tumblr4Rails::Upload" do
        lambda {
          Tumblr4Rails::Writer.create_audio_post("Not correct")
        }.should raise_error
      end
    
    end
  
    describe "create video post" do
    
      it "should raise an exception if the src parameter is blank" do
        lambda {
          Tumblr4Rails::Writer.create_video_post(nil, nil, nil, {})
        }.should raise_error
      end
        
      describe "create uploaded video post" do
        
        before(:each) do
          @upload = Tumblr4Rails::Upload.new("test.wmv", "dfsdffs")
        end
        
        it "should call create_post with a hash including multipart and data" do
          Tumblr4Rails::Writer.should_receive(:create_post).
            with(hash_including(:type => :video, :multipart => true, :data => @upload))
          Tumblr4Rails::Writer.create_video_post(@upload, nil, nil, {})
        end
        
        it "should include the optional parameters when they are supplied" do
          Tumblr4Rails::Writer.should_receive(:create_post).
            with(hash_including(:type => :video, :multipart => true, 
              :data => @upload, :caption => "Caption", :generator => "Test",
              :title => "Title"))
          Tumblr4Rails::Writer.create_video_post(@upload, "Title", "Caption", {:generator => "Test"})
        end
        
      end
      
      describe "create linked video post" do
        
        before(:each) do
          @src = %{<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/6_ynUZ6W7xw&hl=en&fs=1"></param><param name="allowFullScreen" value="true"></param><embed src="http://www.youtube.com/v/6_ynUZ6W7xw&hl=en&fs=1" type="application/x-shockwave-flash" allowfullscreen="true" width="425" height="344"></embed></object>}
        end
        
        it "should call create_post with a hash including source" do
          Tumblr4Rails::Writer.should_receive(:create_post).
            with(hash_including(:type => :video, :embed => @src))
          Tumblr4Rails::Writer.should_not_receive(:create_post).
            with(hash_including(:multipart => true))
          Tumblr4Rails::Writer.create_video_post(@src, nil, nil, {})
        end
        
        it "should include the optional parameters when they are supplied" do
          Tumblr4Rails::Writer.should_receive(:create_post).
            with(hash_including(:type => :video, :embed => @src, :caption => "Caption",
              :title => "Title", :generator => "Test"))
          Tumblr4Rails::Writer.should_not_receive(:create_post).
            with(hash_including(:multipart => true))
          Tumblr4Rails::Writer.create_video_post(@src, "Title", "Caption", {:generator => "Test"})
        end
        
      end
    
    end
  
    describe "create_photo_post" do
      
      it "should raise an exception if the src parameter is blank" do
        lambda {
          Tumblr4Rails::Writer.create_photo_post(nil, nil, nil, {})
        }.should raise_error
      end
        
      describe "create uploaded photo post" do
        
        before(:each) do
          @upload = Tumblr4Rails::Upload.new("test.xml", "dfsdffs")
        end
        
        it "should call create_post with a hash including multipart and data" do
          Tumblr4Rails::Writer.should_receive(:create_post).
            with(hash_including(:type => :photo, :multipart => true, :data => @upload))
          Tumblr4Rails::Writer.create_photo_post(@upload, nil, nil, {})
        end
        
        it "should include the optional parameters when they are supplied" do
          Tumblr4Rails::Writer.should_receive(:create_post).
            with(hash_including(:type => :photo, :multipart => true, 
              :data => @upload, :caption => "Caption", :generator => "Test",
              :"click-through-url" => "http://test.ca"))
          Tumblr4Rails::Writer.create_photo_post(@upload, "Caption", "http://test.ca", {:generator => "Test"})
        end
        
      end
      
      describe "create linked photo post" do
        
        before(:each) do
          @src = "http://test.ca/images/1.jpeg"
        end
        
        it "should call create_post with a hash including source" do
          Tumblr4Rails::Writer.should_receive(:create_post).
            with(hash_including(:type => :photo, :source => @src))
          Tumblr4Rails::Writer.should_not_receive(:create_post).
            with(hash_including(:multipart => true))
          Tumblr4Rails::Writer.create_photo_post(@src, nil, nil, {})
        end
        
        it "should include the optional parameters when they are supplied" do
          Tumblr4Rails::Writer.should_receive(:create_post).
            with(hash_including(:type => :photo, :source => @src, :caption => "Caption",
              :"click-through-url" => "http://test.ca", :generator => "Test"))
          Tumblr4Rails::Writer.should_not_receive(:create_post).
            with(hash_including(:multipart => true))
          Tumblr4Rails::Writer.create_photo_post(@src, "Caption", "http://test.ca", {:generator => "Test"})
        end
        
      end
      
    end
  
    describe "create_post" do
    
      def do_create_post(options={})
        Tumblr4Rails::Writer.send(:create_post, options)
      end
    
      def create_options
        {
          :type => :regular, :title => "Test", :body => "Test", 
          :email => "test@test.ca", :password => "ccxcc"
        }
      end

      before(:each) do
        configure_tumblr_for_application_requests
      end
    
      it "should raise an exception if the post creation options are blank" do
        lambda {
          do_create_post
        }.should raise_error
      end
    
      it "should attempt to cleanup the post options before posting to the API" do
        Tumblr4Rails::Writer.should_receive(:cleanup_post_params).
          with(hash_including(create_options)).and_return(create_options)
        do_create_post(create_options)
      end
    
      it "should post to the API using the post method of the gateway object" do
        @gateway.should_receive(:post_new_post).with(Tumblr4Rails.configuration.write_url,
          hash_including(create_options)).and_return(create_mock_write_response)
        do_create_post(create_options)
      end
    
    end
  
  end
  
  describe "internal methods" do
  
    describe "cleanup_post_params" do
    
      def call_cleanup(options={})
        Tumblr4Rails::Writer.send(:cleanup_post_params, options)
      end
    
      def create_options
        {
          :type => :regular, :title => "Test", 
          :body => "Test"
        }
      end
    
      before(:each) do
        configure_tumblr_for_application_requests
        symbolized = create_options.symbolize_keys
        @handler = mock("Handler")
        @handler.stub!(:process!).and_return(symbolized)
        Tumblr4Rails::WriteOptions::RegularPostHandler.stub!(:new).and_return(@handler)
      end
    
      it "should symbolize all the keys in the options hash" do
        result = call_cleanup(create_options)
        result.keys.each {|k| k.should be_is_a(Symbol)}
      end
      
      it "should get a handler to process the options based on the type" do
        Tumblr4Rails::WriteOptions::RegularPostHandler.should_receive(:new).
          with(hash_including(create_options)).and_return(@handler)
        call_cleanup(create_options)
      end
    
      it "should call get_credentials! if there are no credentials in the options" do
        Tumblr4Rails::Writer.should_receive(:get_credentials!)
        call_cleanup(create_options)
      end
    
      it "should not call get_credentials! if there are crednentials provided in the options" do
        Tumblr4Rails::Writer.should_not_receive(:get_credentials!)
        call_cleanup(create_options.merge(:email => "test@test.ca", :password => "dsdfsdf"))
      end
    
      it "should get the write url unless the write url is provided in the options" do
        Tumblr4Rails::Writer.should_receive(:get_write_url!)
        call_cleanup(create_options)
      end
    
      it "should not attempt to get the write url if it is provided in the options" do
        Tumblr4Rails::Writer.should_not_receive(:get_write_url!)
        call_cleanup(create_options.merge(:write_url => "http://www.test.ca"))
      end
   
    end
  
  end
  
end