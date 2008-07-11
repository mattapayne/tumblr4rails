require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::Read do
    
  describe "dynamically added finders on include" do
    include Tumblr4Rails::Read
    
    it "should add instance method finders to the class including it" do
      finders.each {|meth| self.should respond_to(meth) }
    end
    
  end
  
  describe "dynamically added finders on extend" do
    extend Tumblr4Rails::Read
    
    it "should add class method finders to the class extending it" do
      finders.each {|meth| self.class.should respond_to(meth) }
    end
    
  end
  
  describe "with modules included" do
    include Tumblr4Rails::Read
    
    describe "get_by_id" do
      
      def stubbed_response(response_body)
        resp = mock("Response")
        resp.stub!(:body).and_return(response_body)
        self.gateway.stub!(:get_posts).and_return(resp)
      end
      
      it "should return nil if id is blank" do
        self.get_by_id(nil).should be_nil
      end
      
      it "should return a Tumblr4Rails::Posts object if more than 1 post is returned" do
        stubbed_response(regular_posts_xml)
        posts = self.get_by_id(4534, false, nil)
        posts.should be_is_a(Tumblr4Rails::Posts)
      end
      
      it "should return a single post if only one post is found (which should be the usual)" do
        stubbed_response(video_posts_xml)
        post = self.get_by_id(343432, false, nil)
        post.should be_is_a(Tumblr4Rails::Post)
      end
      
      it "should return JSON if JSON was specified" do
        stubbed_response(regular_posts_json)
        post = self.get_by_id(343432, true, nil)
        post.should be_is_a(String)
      end
      
      it "should return JSON wrapped in the specified callback if JSON and a callback are specified" do
        stubbed_response(regular_posts_json_callback)
        post = self.get_by_id(343432, true, "myCallback")
        post.should =~ /^myCallback(.*)$/
      end
      
    end
    
    describe "posts" do
    
      def default_options(options={})
        {:num => "1", :type => :regular, :start => "1"}.merge(options)
      end
    
      def call_method(options={})
        self.send(:posts, options)
      end
    
      before(:each) do
        configure_tumblr_for_application_requests
        @resp = create_mock_read_response
        @gateway = mock("Gateway")
        @gateway.stub!(:get_posts).and_return(@resp)
        self.stub!(:gateway).and_return(@gateway)
        @posts = mock("Posts")
        self.stub!(:convert_to_ostruct).and_return(@posts)
      end
    
      it "should return nil if the options passed in are blank" do
        call_method.should be_nil
      end
    
      it "should symbolize all keys in the options hash" do
        options = {"num" => "1", "type" => :regular, "start" => "2"}
        symbolized = options.symbolize_keys
        options.should_receive(:symbolize_keys).and_return(symbolized)
        call_method(options)
      end
    
      it "should call translate_read_param_aliases!" do
        self.should_receive(:translate_read_param_aliases!)
        call_method(default_options)
      end
    
      it "should merge the params with the default read params" do
        self.should_receive(:merge_params_with_default_params!)
        call_method(default_options)
      end
    
      it "should extract the json param to determine if this should be a json read" do
        self.should_receive(:extract_json!).and_return(false)
        call_method(default_options)
      end
    
      it "should remove blank and invalid params" do
        self.should_receive(:remove_blank_and_invalid_read_params!)
        call_method(default_options)
      end
    
      it "should call remove_read_params_if_id_provided! if an id was provided" do
        self.should_receive(:remove_unecessary_read_params!)
        call_method(default_options(:id => "10"))
      end
    
      it "should ensure the tumblr type if no id is specified in the options" do
        self.should_receive(:ensure_post_type!)
        call_method(default_options)
      end
    
      it "should not ensure the tumblr type if an id is specified in the options" do
        self.should_not_receive(:ensure_post_type!)
        call_method(default_options(:id => "12"))
      end
    
      it "should call ensure_number!" do
        self.should_receive(:ensure_number!)
        call_method(default_options)
      end
    
      it "should use the gateway to do a get to the API" do
        @gateway.should_receive(:get_posts).and_return(@resp)
        call_method(default_options)
      end
    
      it "should return the response body if json is true" do
        call_method(default_options(:json => true)).should be_is_a(String)
      end
    
      it "should not return a String if json is false" do
        call_method(default_options).should_not be_is_a(String)
      end
    
    end
    
    describe "extract_json!" do
      
      it "should return true if json => true is in the options hash" do
        self.send(:extract_json!, {:json => true}).should be_true
      end
      
      it "should return false if json => false is in the options hash" do
        self.send(:extract_json!, {:json => false}).should be_false
      end
      
      it "should return false if the options hash has no json key/value" do
        self.send(:extract_json!, {}).should be_false
      end
      
    end
    
    describe "merge_params_with_default_params!" do
      
      def call_method(options)
        self.send(:merge_params_with_default_params!, options)
      end
      
      it "should overwrite the default params with the passed in params" do
        options = {:type => "test", :generator => "blah"}
        call_method(options)
        options.should have(8).items
        options[:type].should == "test"
        options[:generator].should == "blah"
      end
      
    end
    
    describe "remove_callback!" do
      
      def call_method(options)
        self.send(:remove_callback!, options)
      end
      
      it "should remove the callback key/value if it exists" do
        options = {:type => "test", :callback => "dffsff"}
        call_method(options)
        options.should have(1).items
        options.should_not be_key(:callback)
      end
      
      it "should gracefully handle the case where the callback key/value does not exist" do
        options = {:type => "test"}
        lambda {call_method(options) }.should_not raise_error
        options.should have(1).items
        options.should_not be_key(:callback)
      end
      
    end
  
    describe "remove_blank_and_invalid_read_params!" do
    
      def call_method(options)
        self.send(:remove_blank_and_invalid_read_params!, options)
      end
    
      it "should remove all entries with blank values" do
        options = {:type => "test", :num => "", :start => nil}
        call_method(options)
        options.should have(1).items
        options[:type].should_not be_nil
      end
    
      it "should remove all entries with invalid keys" do
        options = {:type => "test", :b => "ddd", :c => "dfdfsd"}
        call_method(options)
        options.should have(1).items
        options[:type].should_not be_nil
      end
    
    end
  
    describe "generate_read_url" do
     
      def call_method(options, json)
        self.send(:generate_read_url, options, json)
      end
    
      it "should generate a url with json if json specified" do
        options = {:type => :regular, :read_url => "http://www.something.something.com"}
        url = call_method(options, true)
        url.should == "http://www.something.something.com/json?type=regular"
      end
    
      it "should not generate a url with json if json not specified" do
        options = {:type => :regular, :read_url => "http://www.something.something.com"}
        url = call_method(options, false)
        url.should == "http://www.something.something.com?type=regular"
      end
    
      it "should generate a url with the correct parameters" do
        options = {:type => :regular, :read_url => "http://www.something.something.com"}
        url = call_method(options, false)
        url.should == "http://www.something.something.com?type=regular"
      end
    
    end
    
    describe "ensure_read_url!" do
      
      def call_method(options)
        self.send(:ensure_read_url!, options)
      end
      
      it "should not raise an exception if the read_url can be determined from the settings" do
        configure_tumblr_for_application_requests
        lambda {call_method({})}.should_not raise_error
      end
      
      it "should raise an exception if the read_url cannot be determined from the settings" do
        configure_tumblr_for_request_requests
        lambda {call_method({})}.should raise_error
      end
      
      it "should add the read_url to the options if it can be determined from the settings" do
        configure_tumblr_for_application_requests
        options = {}
        call_method(options)
        options.should have(1).items
        options[:read_url].should_not be_nil
      end
      
    end
  
    describe "ensure_post_type!" do
    
      def call_method(options)
        self.send(:ensure_post_type!, options)
      end
    
      it "should return immediately if type is blank" do
        options = {:num => "3"}
        self.should_not_receive(:post_types)
        call_method(options)
      end
    
      it "should raise an exception if the type is not within the allowed types" do
        options = {:type => "test"}
        lambda {
          call_method(options)
        }.should raise_error
      end
    
      it "should not raise an exception if the type is within the allowed types" do
        options = {:type => :link}
        lambda {
          call_method(options)
        }.should_not raise_error
      end
     
    end
  
    describe "ensure_number!" do
    
      def call_method(options)
        self.send(:ensure_number!, options)
      end
    
      it "should convert the passed in number to the minimum allowed if less than 0" do
        options = {:num => -1}
        call_method(options)
        options[:num].should == 1
      end
    
      it "should convert the passed in number to the max allowed if greater than max" do
        options = {:num => 5000}
        call_method(options)
        options[:num].should == 50
      end
    
      it "should not mess with the passed in number if its within the allowed range" do
        options = {:num => 4}
        call_method(options)
        options[:num].should == 4
      end
    
    end
  
    describe "remove_unecessary_read_params!" do
      
      def call_method(options)
        self.send(:remove_unecessary_read_params!, options)
      end
    
      it "should remove start, num and type but not id" do
        options = {:start => "1", :num => "2", :type => :regular, :id => "3"}
        call_method(options)
        options.should have(1).items
        options.keys.should be_include(:id)
      end
    
    end
  
    describe "translate_read_param_aliases!" do
    
      def call_method(options)
        self.send(:translate_read_param_aliases!, options)
      end
    
      it "should translate index to start" do
        options = {:index => 12}
        call_method(options)
        options.should have(1).items
        options.keys.should be_include(:start)
        options[:start].should == 12
      end
    
      it "should translate limit to num" do
        options = {:limit => 2}
        call_method(options)
        options.should have(1).items
        options.keys.should be_include(:num)
        options[:num].should == 2
      end
    
    end
    
    describe "cleanup_read_params!" do
      
      def call_method(options, json=false)
        self.send(:cleanup_read_params!, options, json)
      end
      
      before(:each) do
        configure_tumblr_for_application_requests
      end
      
      it "should translate read param aliases" do
        self.should_receive(:translate_read_param_aliases!)
        call_method({})
      end
      
      it "should merge options with the default read options" do
        self.should_receive(:merge_params_with_default_params!)
        call_method({})
      end
      
      it "should remove blank and invalid read params" do
        self.should_receive(:remove_blank_and_invalid_read_params!)
        call_method({})
      end
      
      it "should remove the callback param if it exists and json is false" do
        self.should_receive(:remove_callback!)
        options = {:callback => "dfsdfsdfd"}
        call_method(options)
      end
      
      it "should not remove the callback param if it exists and json is true" do
        self.should_not_receive(:remove_callback!)
        options = {:callback => "dfsdfsdfd"}
        call_method(options, true)
      end
      
      it "should not remove the callback if it does not exist and json is true" do
        self.should_not_receive(:remove_callback!)
        call_method({}, true)
      end
      
      it "should remove unecessary read params if an id is provided" do
        self.should_receive(:remove_unecessary_read_params!)
        options = {:id => "43435"}
        call_method(options)
      end
      
      it "should not remove unecessary read params if an id is not provided" do
        self.should_not_receive(:remove_unecessary_read_params!)
        call_method({})
      end
      
      it "should ensure the post type if an id is not provided" do
        self.should_receive(:ensure_post_type!)
        call_method({})
      end
      
      it "should not ensure the post type if an id is provided" do
        self.should_not_receive(:ensure_post_type!)
        options = {:id => "4343554"}
        call_method(options)
      end
      
      it "should ensure the number if the number is provided" do
        self.should_receive(:ensure_number!)
        options = {:num => 12}
        call_method(options)
      end
      
      it "should not ensure the number if the number is not provided" do
        self.should_not_receive(:ensure_number!)
        call_method({})
      end
      
      it "should attempt to get the read url from the settings if it is not provided" do
        self.should_receive(:ensure_read_url!)
        call_method({})
      end
      
      it "should not attempt to get the read url from the settings if it is provided" do
        self.should_not_receive(:ensure_read_url!)
        options = {:read_url => "http://www.test.ca"}
        call_method(options)
      end
    end
    
  end
  
end