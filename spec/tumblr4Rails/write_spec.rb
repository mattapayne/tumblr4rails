require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::Write do
  include Tumblr4Rails::Write
  
  before(:each) do
    @gateway = mock("Gateway")
    self.stub!(:gateway).and_return(@gateway)
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
        self.stub!(:do_write_action).and_return(@resp)
        self.can_upload_audio?(mock_hash)
      end
    
      it "should return true if the response code is 200" do
        self.can_upload_audio?(:email => "test@test.ca", :password => "dfsdf").should be_true
      end
    
      it "should return false if the response code is not 200" do
        @resp.stub!(:code).and_return("400")
        self.can_upload_audio?(:email => "test@test.ca", :password => "dfsdf").should be_false
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
        self.stub!(:do_write_action).and_return(@resp)
        self.video_upload_permissions(mock_hash)
      end
    
      it "should return an instance of Tumblr4Rails::UploadPermission" do
        resp = self.video_upload_permissions(:email => "test@test.ca", :password => "sdsddff")
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
        self.stub!(:do_write_action).and_return(@resp)
        self.authenticated?(mock_hash)
      end
    
      it "should return true if the response code is 200" do
        self.authenticated?({:email => "test@test.ca", :password => "xxx"}).should be_true
      end
    
      it "should return false if the response code is not 200" do
        @resp.stub!(:code).and_return("400")
        self.authenticated?({:email => "test@test.ca", :password => "xxx"}).should be_false
      end
    
    end
  
    describe "authenticated? with request_type == :request" do

      before(:each) do
        configure_tumblr_for_request_requests
        @resp = create_mock_authenticated_response
        @gateway.stub!(:execute_query).and_return(@resp)
      end
    
      it "should be authenticated if the email and password are provided" do
        self.authenticated?({:password => "xxx", :email => "test@test.ca"}).should be_true
      end
    
      it "should raise an exception if the email is not passed in" do
        lambda {
          self.authenticated?({:password => "xxx"}).should be_false
        }.should raise_error
      end
    
      it "should raise an exception if the email passed in is blank" do
        lambda {
          self.authenticated?({:email => nil, :password => "xxx"}).should be_false
        }.should raise_error
      end
    
      it "should raise an exception if the passowrd is not passed in" do
        lambda {
          self.authenticated?({:email => "test@test.ca"}).should be_false
        }.should raise_error
      end
    
      it "should raise an exception if the password passed in is blank" do
        lambda {
          self.authenticated?({:email => "test@test.ca", :password => nil}).should be_false
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
        self.authenticated?.should be_true
      end
   
      it "should raise an exception if the email is nil" do
        self.stub!(:email).and_return(nil)
        lambda{
          self.authenticated?
        }.should raise_error
      end
    
      it "should raise an exception if the email is blank" do
        self.stub!(:email).and_return("")
        lambda {
          self.authenticated?
        }.should raise_error
      end
    
      it "should raise an exception if the password is nil" do
        self.stub!(:password).and_return(nil)
        lambda{
          self.authenticated?
        }.should raise_error
      end
    
      it "should raise an exception if the password is blank" do
        self.stub!(:password).and_return("")
        lambda {
          self.authenticated?
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
        self.should_receive(:create_post).with(
          hash_including(:type => :regular, :title => "Title", :body => "Body"))
        self.create_regular_post("Title", "Body")
      end
    
      it "should receive args with additional arguments included" do
        self.should_receive(:create_post).with(
          hash_including(:generator => "Test", :private => "1"))
        self.create_regular_post("Title", "Body", {:generator => "Test", :private => "1"})
      end
    
    end
  
    describe "create link post" do
    
      it "should receive args with the proper contents" do
        self.should_receive(:create_post).with(
          hash_including(:type => :link, :url => "http://www.google.ca")
        ).and_return(@resp)
        self.create_link_post("http://www.google.ca")
      end
    
      it "should receive args with additional arguments included" do
        self.should_receive(:create_post).with(
          hash_including(:generator => "Test", :private => "0", :name => "Google",
            :description => "A Search Engine")
        ).and_return(@resp)
        self.create_link_post("http://www.google.ca", 
          "Google", "A Search Engine", {:generator => "Test", :private => "0"})
      end
    
    end
  
    describe "create conversation post" do
    
      it "should receive args with the proper contents" do
        self.should_receive(:create_post).with(
          hash_including(:type => :conversation, :conversation => "blah")
        ).and_return(@resp)
        self.create_conversation_post("blah", nil)
      end
    
      it "should receive args with additional arguments included" do
        self.should_receive(:create_post).with(
          hash_including(:generator => "Test", :private => "0", :conversation => "blah")
        ).and_return(@resp)
        self.create_conversation_post("blah", nil, {:generator => "Test", :private => "0"})
      end
    
    end
  
    describe "create quote post" do
    
      it "should receive args with the proper contents" do
        self.should_receive(:create_post).with(
          hash_including(:type => :quote, :quote => "a quote")
        ).and_return(@resp)
        self.create_quote_post("a quote")
      end
    
      it "should receive args with additional arguments included" do
        self.should_receive(:create_post).with(
          hash_including(:generator => "Test", :private => "0", :quote => "a quote", :source => "A Source")
        ).and_return(@resp)
        self.create_quote_post("a quote", "A Source", {:generator => "Test", :private => "0"})
      end
    
    end
  
    describe "create audio post" do
    
      before(:each) do
        @data = Tumblr4Rails::Upload.new("file.xml", "text/xml", "some data")
      end
    
      it "should receive args with the proper contents" do
        self.should_receive(:create_post).with(
          hash_including(:type => :audio, :data => @data, 
            :multipart => true)).and_return(@resp)
        self.create_audio_post(@data)
      end
    
      it "should receive args with additional arguments included" do
        self.should_receive(:create_post).with(
          hash_including(:generator => "Test", :private => "0", :multipart => true,
            :caption => "A Song", :data => @data)).and_return(@resp)
        self.create_audio_post(@data, "A Song", {:generator => "Test", :private => "0"})
      end
    
      it "should raise an error if the data parameter is not an instance of Tumblr4Rails::Upload" do
        lambda {
          self.create_audio_post("Not correct")
        }.should raise_error
      end
    
    end
  
    describe "create video post" do
    
      it "should raise an exception if the src parameter is blank" do
        lambda {
          self.create_video_post(nil, nil, nil, {})
        }.should raise_error
      end
        
      describe "create uploaded video post" do
        
        before(:each) do
          @upload = Tumblr4Rails::Upload.new("test.wmv", "dfsdffs")
        end
        
        it "should call create_post with a hash including multipart and data" do
          self.should_receive(:create_post).
            with(hash_including(:type => :video, :multipart => true, :data => @upload))
          self.create_video_post(@upload, nil, nil, {})
        end
        
        it "should include the optional parameters when they are supplied" do
          self.should_receive(:create_post).
            with(hash_including(:type => :video, :multipart => true, 
              :data => @upload, :caption => "Caption", :generator => "Test",
              :title => "Title"))
          self.create_video_post(@upload, "Title", "Caption", {:generator => "Test"})
        end
        
      end
      
      describe "create linked video post" do
        
        before(:each) do
          @src = %{<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/6_ynUZ6W7xw&hl=en&fs=1"></param><param name="allowFullScreen" value="true"></param><embed src="http://www.youtube.com/v/6_ynUZ6W7xw&hl=en&fs=1" type="application/x-shockwave-flash" allowfullscreen="true" width="425" height="344"></embed></object>}
        end
        
        it "should call create_post with a hash including source" do
          self.should_receive(:create_post).
            with(hash_including(:type => :video, :embed => @src))
          self.should_not_receive(:create_post).
            with(hash_including(:multipart => true))
          self.create_video_post(@src, nil, nil, {})
        end
        
        it "should include the optional parameters when they are supplied" do
          self.should_receive(:create_post).
            with(hash_including(:type => :video, :embed => @src, :caption => "Caption",
              :title => "Title", :generator => "Test"))
          self.should_not_receive(:create_post).
            with(hash_including(:multipart => true))
          self.create_video_post(@src, "Title", "Caption", {:generator => "Test"})
        end
        
      end
    
    end
  
    describe "create_photo_post" do
      
      it "should raise an exception if the src parameter is blank" do
        lambda {
          self.create_photo_post(nil, nil, nil, {})
        }.should raise_error
      end
        
      describe "create uploaded photo post" do
        
        before(:each) do
          @upload = Tumblr4Rails::Upload.new("test.xml", "dfsdffs")
        end
        
        it "should call create_post with a hash including multipart and data" do
          self.should_receive(:create_post).
            with(hash_including(:type => :photo, :multipart => true, :data => @upload))
          self.create_photo_post(@upload, nil, nil, {})
        end
        
        it "should include the optional parameters when they are supplied" do
          self.should_receive(:create_post).
            with(hash_including(:type => :photo, :multipart => true, 
              :data => @upload, :caption => "Caption", :generator => "Test",
              :"click-through-url" => "http://test.ca"))
          self.create_photo_post(@upload, "Caption", "http://test.ca", {:generator => "Test"})
        end
        
      end
      
      describe "create linked photo post" do
        
        before(:each) do
          @src = "http://test.ca/images/1.jpeg"
        end
        
        it "should call create_post with a hash including source" do
          self.should_receive(:create_post).
            with(hash_including(:type => :photo, :source => @src))
          self.should_not_receive(:create_post).
            with(hash_including(:multipart => true))
          self.create_photo_post(@src, nil, nil, {})
        end
        
        it "should include the optional parameters when they are supplied" do
          self.should_receive(:create_post).
            with(hash_including(:type => :photo, :source => @src, :caption => "Caption",
              :"click-through-url" => "http://test.ca", :generator => "Test"))
          self.should_not_receive(:create_post).
            with(hash_including(:multipart => true))
          self.create_photo_post(@src, "Caption", "http://test.ca", {:generator => "Test"})
        end
        
      end
      
    end
  
    describe "create_post" do
    
      def do_create_post(options={})
        self.send(:create_post, options)
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
        self.should_receive(:cleanup_write_params).
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
    
    describe "ensure_necessary_write_params_present!" do
    
      def call_method(options)
        self.send(:ensure_necessary_write_params_present!, options)
      end
    
      def create_options
        {
          :type => :regular, :title => "Test", :body => "Test", 
          :email => "test@test.ca", :password => "dfd"
        }
      end
    
      it "should raise an exception if no type is present" do
        lambda {call_method(create_options.merge(:type => nil))}.should raise_error
      end
    
      it "should raise an exception if no credentials are present" do
        lambda {call_method(create_options.merge(:email => nil, :password => nil))}.should raise_error
      end
    
      it "should raise an exception if params for a given type are not present" do
        lambda {call_method(create_options.merge(:title => nil))}.should raise_error
      end
    
      it "should not raise an exception if all params are present" do
        lambda {call_method(create_options)}.should_not raise_error
      end
    
    end
  
    describe "cleanup_write_params" do
    
      def call_cleanup(options={})
        self.send(:cleanup_write_params, options)
      end
    
      def create_options
        {
          "type" => :regular, "title" => "Test", :body => "Test"
        }
      end
    
      before(:each) do
        configure_tumblr_for_application_requests
      end
    
      it "should symbolize all the keys in the options hash" do
        options = create_options
        result = call_cleanup(options)
        result.keys.each {|k| k.should be_is_a(Symbol)}
      end
    
      it "should call get_credentials! if there are no credentials in the options" do
        self.stub!(:ensure_necessary_write_params_present!)
        self.should_receive(:get_credentials!)
        call_cleanup(create_options)
      end
    
      it "should not call get_credentials! if there are crednentials provided in the options" do
        self.should_not_receive(:get_credentials!)
        call_cleanup(create_options.merge(:email => "test@test.ca", :password => "dsdfsdf"))
      end
    
      it "should call remove_blank_or_invalid_write_params!" do
        self.should_receive(:remove_blank_or_invalid_write_params!)
        call_cleanup(create_options)
      end
    
      it "should call convert_write_param_values!" do
        self.should_receive(:convert_write_param_values!)
        call_cleanup(create_options)
      end
    
      it "should call ensure_write_param_values_pass_validation!" do
        self.should_receive(:ensure_write_param_values_pass_validation!)
        call_cleanup(create_options)
      end
    
      it "should call ensure_necessary_write_params_present!" do
        self.should_receive(:ensure_necessary_write_params_present!)
        call_cleanup(create_options)
      end
    
      it "should get the write url unless the write url is provided in the options" do
        self.should_receive(:get_write_url!)
        call_cleanup(create_options)
      end
    
      it "should not attempt to get the write url if it is provided in the options" do
        self.should_not_receive(:get_write_url!)
        call_cleanup(create_options.merge(:write_url => "http://www.test.ca"))
      end
   
    end
  
    describe "remove_blank_or_invalid_write_params!" do
    
      def call_method(options={})
        self.send(:remove_blank_or_invalid_write_params!, options)
      end
    
      it "should remove all entries with blank values" do
        options = {:type => "test", :caption => nil, :title => "", :date => nil}
        result = call_method(options)
        result.should have(1).items
        result.key?(:type).should be_true
      end
    
      it "should remove all entries with invalid keys" do
        options = {:type => "test", :xxx => "dfdfsdf", :yyy => "fsdfdf"}
        result = call_method(options)
        result.should have(1).items
        result.key?(:type).should be_true
      end
    
      describe "with type = link" do
      
        it "should remove all params that are not valid for the type" do
          opts = {
            :type => :link, :url => "http://www.google.ca",
            :name => "test", :description => "blah", :xxx => 12,
            :generator => "test", :private => true
          }
          call_method(opts)
          opts.should have(6).items
          opts[:type].should == :link
          opts[:url].should == "http://www.google.ca"
          opts[:name].should == "test"
          opts[:description].should == "blah"
          opts[:generator].should == "test"
          opts[:private].should == true
        end
      
        it "should remove all params that are blank" do
          opts = {
            :type => :link, :url => "http://www.google.ca",
            :name => "", :description => "",
            :generator => "test", :private => true
          }
          call_method(opts)
          opts.should have(4).items
          opts[:type].should == :link
          opts[:url].should == "http://www.google.ca"
          opts[:generator].should == "test"
          opts[:private].should == true
        end
      
      end
    
      describe "with type = regular" do
      
        it "should remove all params that are not valid for the type" do
          opts = {
            :type => :regular, :url => "http://www.google.ca",
            :title => "test", :body => "blah", :xxx => 12,
            :generator => "test", :private => true
          }
          call_method(opts)
          opts.should have(5).items
          opts[:type].should == :regular
          opts[:title].should == "test"
          opts[:body].should == "blah"
          opts[:generator].should == "test"
          opts[:private].should == true
        end
      
        it "should remove all params that are blank" do
          opts = {
            :type => :regular, :title => "", :body => "",
            :generator => "test", :private => true
          }
          call_method(opts)
          opts.should have(3).items
          opts[:type].should == :regular
          opts[:generator].should == "test"
          opts[:private].should == true
        end
      
      end
    
      describe "with type = conversation" do
      
        it "should remove all params that are not valid for the type" do
          opts = {
            :type => :conversation, :url => "http://www.google.ca",
            :conversation => "test", :title => "blah", :xxx => 12,
            :generator => "test", :private => true
          }
          call_method(opts)
          opts.should have(5).items
          opts[:type].should == :conversation
          opts[:conversation].should == "test"
          opts[:title].should == "blah"
          opts[:generator].should == "test"
          opts[:private].should == true
        end
      
        it "should remove all params that are blank" do
          opts = {
            :type => :conversation, :title => "", :conversation => "",
            :generator => "test", :private => true
          }
          call_method(opts)
          opts.should have(3).items
          opts[:type].should == :conversation
          opts[:generator].should == "test"
          opts[:private].should == true
        end
      
      end
    
      describe "with type = quote" do
      
        it "should remove all params that are not valid for the type" do
          opts = {
            :type => :quote, :source => "http://www.google.ca",
            :monkey => "test", :title => "blah", :xxx => 12,
            :generator => "test", :private => true, :quote => "sdffdf"
          }
          call_method(opts)
          opts.should have(5).items
          opts[:type].should == :quote
          opts[:quote].should == "sdffdf"
          opts[:source].should == "http://www.google.ca"
          opts[:generator].should == "test"
          opts[:private].should == true
        end
      
        it "should remove all params that are blank" do
          opts = {
            :type => :quote, :source => "", :quote => "ssdffdfsd",
            :generator => "test", :private => true
          }
          call_method(opts)
          opts.should have(4).items
          opts[:type].should == :quote
          opts[:quote].should == "ssdffdfsd"
          opts[:generator].should == "test"
          opts[:private].should == true
        end
      
      end
    
      describe "with type = video" do
      
        it "should remove all params that are not valid for the type" do
          opts = {
            :type => :video, :embed => "http://www.google.ca",
            :monkey => "test", :title => "blah", :data => 12,
            :generator => "test", :private => true, :quote => "sdffdf"
          }
          call_method(opts)
          opts.should have(6).items
          opts[:type].should == :video
          opts[:embed].should == "http://www.google.ca"
          opts[:title].should == "blah"
          opts[:data].should == 12
          opts[:generator].should == "test"
          opts[:private].should == true
        end
      
        it "should remove all params that are blank" do
          opts = {
            :type => :video, :embed => "", :data => nil,
            :generator => "test", :private => true
          }
          call_method(opts)
          opts.should have(3).items
          opts[:type].should == :video
          opts[:generator].should == "test"
          opts[:private].should == true
        end
      
      end
    
      describe "with type = audio" do
      
        it "should remove all params that are not valid for the type" do
          opts = {
            :type => :audio, :data => "http://www.google.ca",
            :monkey => "test", :caption => "blah",
            :generator => "test", :private => true, :quote => "sdffdf"
          }
          call_method(opts)
          opts.should have(5).items
          opts[:type].should == :audio
          opts[:data].should == "http://www.google.ca"
          opts[:caption].should == "blah"
          opts[:generator].should == "test"
          opts[:private].should == true
        end
      
        it "should remove all params that are blank" do
          opts = {
            :type => :audio, :data => "", :caption => nil,
            :generator => "test", :private => true
          }
          call_method(opts)
          opts.should have(3).items
          opts[:type].should == :audio
          opts[:generator].should == "test"
          opts[:private].should == true
        end
      
      end
    
      describe "with type = photo" do
      
        it "should remove all params that are not valid for the type" do
          opts = {
            :type => :photo, :data => "http://www.google.ca",
            :monkey => "test", :caption => "blah", :source => "test",
            :"click-through-url" => "http://www.google.ca",
            :generator => "test", :private => true, :quote => "sdffdf"
          }
          call_method(opts)
          opts.should have(7).items
          opts[:type].should == :photo
          opts[:data].should == "http://www.google.ca"
          opts[:caption].should == "blah"
          opts[:source].should == "test"
          opts[:"click-through-url"].should == "http://www.google.ca"
          opts[:generator].should == "test"
          opts[:private].should == true
        end
      
        it "should remove all params that are blank" do
          opts = {
            :type => :photo, :data => "", :caption => nil, :source => "test",
            :generator => "test", :private => true
          }
          call_method(opts)
          opts.should have(4).items
          opts[:type].should == :photo
          opts[:generator].should == "test"
          opts[:private].should == true
          opts[:source].should == "test"
        end
      
      end
    
    end
  
    describe "convert_write_param_values!" do
    
      def call_method(options={})
        self.send(:convert_write_param_values!, options)
      end
    
      def convert_date(date)
        date.strftime(Tumblr4Rails::Write::WriteMethods::DATE_FORMAT)
      end
    
      it "should convert a Date to a string" do
        d = Date.today
        s = convert_date(d)
        options = {:date => d, :type => :regular}
        call_method(options)
        options[:date].should == s
      end
        
      it "should convert a DateTime to a string" do
        d = DateTime.now
        s = convert_date(d)
        options = {:date => d, :type => :regular}
        call_method(options)
        options[:date].should == s
      end
    
    end
  
    describe "ensure_write_param_values_pass_validation!" do
    
      def call_method(options={})
        self.send(:ensure_write_param_values_pass_validation!, options)
      end
    
      def create_options(options={})
        {
          :type => :regular, :title => "Title", :body => "Body", :private => "0",
          :date => DateTime.now, :generator => "This test", :email => "test@test.ca",
          :password => "dzcsdscf", :tags => "Ruby, XXX", :format => "html", 
          :group => "http://group.tumblr.com"
        }.merge(options)
      end
    
      it "should raise an exception if type is not one of the defined post types" do
        opts = create_options(:type => :blah)
        lambda {
          call_method(opts)
        }.should raise_error
      end
    
      it "should raise an exception if the email is not in a valid format" do
        opts = create_options(:email => "ffdfdf")
        lambda {
          call_method(opts)
        }.should raise_error
      end
    
      it "should raise an exception if the generator is greater than the max length allowed" do
        opts = create_options(
          :generator => "ffdfdfcdfddfsdfdfdfdfdfdsfsfdfdfsdfsdfsfsfdfffsffdffdfsdfsdfdsdfsd")
        lambda {
          call_method(opts)
        }.should raise_error
      end
    
      it "should raise an exception if private is not '1' or '0'" do
        opts = create_options(:private => "ffdfdf")
        lambda {
          call_method(opts)
        }.should raise_error
      end
    
      it "should raise an exception if format is not 'html' or 'markdown'" do
        opts = create_options(:format => "ffdfdf")
        lambda {
          call_method(opts)
        }.should raise_error
      end
    
      it "should raise an exception if group is not a proper url" do
        opts = create_options(:group => "ffdfdf")
        lambda {
          call_method(opts)
        }.should raise_error
      end
    
      it "should raise an exception if source is not a proper url" do
        opts = create_options(:source => "ffdfdf")
        lambda {
          call_method(opts)
        }.should raise_error
      end
    
      it "should raise an exception if click-through-url is not a proper url" do
        opts = create_options(:"click-through-url" => "ffdfdf")
        lambda {
          call_method(opts)
        }.should raise_error
      end
    
      it "should raise an exception if url is not a proper url" do
        opts = create_options(:url => "ffdfdf")
        lambda {
          call_method(opts)
        }.should raise_error
      end
    
    end
  
    describe "converting param values" do
    
      def conversions
        self.send(:write_param_conversions)
      end
    
      it "should properly convert private set to 'true'" do
        conversions[:private].call(true).should == "1"
      end
    
      it "should properly convert private set to 'false'" do
        conversions[:private].call(false).should == "0"
      end
    
      it "should properly convert private set to '1'" do
        conversions[:private].call("1").should == "1"
      end
    
      it "should properly convert private set to '0'" do
        conversions[:private].call("0").should == "0"
      end
    
      it "should properly convert a date" do
        d = Date.today
        str = d.strftime("%m/%d/%Y %I:%M:%S")
        conversions[:date].call(d).should == str
      end
    
      it "should properly convert a DateTime" do
        d = DateTime.now
        str = d.strftime("%m/%d/%Y %I:%M:%S")
        conversions[:date].call(d).should == str
      end
    
    end
  
    describe "write_param_validations" do
    
      def default_options(alt_opts={})
        {
          :email => "test@test.ca",
          :type => Tumblr4Rails::PostType.regular.name,
          :generator => "this app",
          :private => "1",
          :format => "html",
          :group => 12345,
          :source => "http://test.ca",
          :"click-through-url" => "http://click_through.com",
          :url => "http://www.someurl.com",
          :read_url => "http://www.somereadurl.org",
          :write_url => "http://somerandomwriteurl.ca"
        }.merge(alt_opts)
      end
    
      def validators
        self.send(:write_param_validations)
      end
    
      it "should pass the params as supplied" do
        opts = default_options 
        opts.each {|k, v| validators[k].call(v).should be_true}
      end
    
      it "should fail on a bad email" do
        validators[:email].call("dfds").should be_false
      end
    
      it "should fail on an invalid type" do
        validators[:type].call("monkey").should be_false
      end
    
      it "should fail on a bad generator" do
        validators[:generator].call(
          "tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt").
          should be_false
      end
    
      it "should fail on an invalid private value" do
        validators[:private].call("Monkey").should be_false
      end
    
      it "should pass on an alternative private value" do
        validators[:private].call(true).should be_true
      end
    
      it "should fail on an invalid format" do
        validators[:format].call("something bad").should be_false
      end
    
      it "should pass on an alternative group value" do
        validators[:group].call("http://www.group.something.com").should be_true
      end
    
      it "should fail on an invalid group" do
        validators[:group].call("gdfgdfgd").should be_false
      end
    
      it "should fail on all of the following with bad values" do
        [:read_url, :write_url, :source, :"click-through-url", :url].each do |val|
          validators[val].call("Crap").should be_false
        end
      end
    
    end
  
  end
  
end