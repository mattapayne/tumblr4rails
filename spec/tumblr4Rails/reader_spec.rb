require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::Reader do

  describe "dynamically added finders" do
    
    it "should add instance method finders" do
      finders.each {|meth| Tumblr4Rails::Reader.should respond_to(meth) }
    end
    
  end
    
  def default_options(options={})
    {:num => "1", :type => :regular, :start => "1"}.merge(options)
  end
    
  before(:each) do
    @gateway = mock("Gateway")
    Tumblr4Rails::Reader.stub!(:gateway).and_return(@gateway)
  end
  
  describe "get_by_id" do
      
    def stub_gateway_call(response_body)
      resp = mock("Response")
      resp.stub!(:body).and_return(response_body)
      @gateway.stub!(:get_posts).and_return(resp)
    end
    
    it "should return nil if id is blank" do
      Tumblr4Rails::Reader.get_by_id(nil).should be_nil
    end
      
    it "should return a Tumblr4Rails::Posts object if more than 1 post is returned" do
      stub_gateway_call(regular_posts_xml)
      posts = Tumblr4Rails::Reader.get_by_id(4534, false, nil)
      posts.should be_is_a(Tumblr4Rails::Posts)
    end
      
    it "should return a single post if only one post is found (which should be the usual)" do
      stub_gateway_call(video_posts_xml)
      post = Tumblr4Rails::Reader.get_by_id(343432, false, nil)
      post.should be_is_a(Tumblr4Rails::Post)
    end
      
    it "should return JSON if JSON was specified" do
      stub_gateway_call(regular_posts_json)
      post = Tumblr4Rails::Reader.get_by_id(343432, true, nil)
      post.should be_is_a(String)
    end
      
    it "should return JSON wrapped in the specified callback if JSON and a callback are specified" do
      stub_gateway_call(regular_posts_json_callback)
      post = Tumblr4Rails::Reader.get_by_id(343432, true, "myCallback")
      post.should =~ /^myCallback(.*)$/
    end
      
  end
    
  describe "posts" do
    
    def call_posts(options={})
      Tumblr4Rails::Reader.send(:posts, options)
    end
    
    before(:each) do
      configure_tumblr_for_application_requests
      @resp = mock("Response")
      @resp.stub!(:body).and_return(regular_posts_xml)
      @gateway.stub!(:get_posts).and_return(@resp)
    end
    
    it "should return nil if the options passed in are blank" do
      call_posts().should be_nil
    end
      
    it "should create an instance of Tumblr4Rails::ReadOptions::ReadHandler and call process!" do
      handler = mock("Handler")
      handler.should_receive(:process!).and_return(default_options)
      Tumblr4Rails::ReadOptions::ReadHandler.should_receive(:new).and_return(handler)
      call_posts(default_options)
    end
    
    it "should symbolize all keys in the options hash" do
      options = {"num" => "1", "type" => :regular, "start" => "2"}
      symbolized = options.symbolize_keys
      options.should_receive(:symbolize_keys).and_return(symbolized)
      call_posts(options)
    end
    
    it "should use the gateway to do a get to the API" do
      @gateway.should_receive(:get_posts).and_return(@resp)
      call_posts(default_options)
    end
    
    it "should return the response body if json is true" do
      call_posts(default_options(:json => true)).should be_is_a(String)
    end
    
    it "should not return a String if json is false" do
      call_posts(default_options).should_not be_is_a(String)
    end
    
  end
  
  describe "generate_read_url" do
      
    def call_method(options, json)
      Tumblr4Rails::Reader.send(:generate_read_url, options, json)
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
      options = {:type => :regular, :limit => 2, :read_url => "http://www.something.something.com"}
      url = call_method(options, false)
      url.should == "http://www.something.something.com?limit=2&type=regular"
    end
    
  end
    
  describe "ensure_read_url!" do
      
    def call_method(options)
      Tumblr4Rails::Reader.send(:ensure_read_url!, options)
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
  
  describe "cleanup_read_params!" do
      
    def call_method(options)
      Tumblr4Rails::Reader.send(:cleanup_read_params!, options)
    end
      
    before(:each) do
      configure_tumblr_for_application_requests
    end
      
    it "should attempt to get the read url from the settings if it is not provided" do
      Tumblr4Rails::Reader.should_receive(:ensure_read_url!)
      call_method(default_options)
    end
      
    it "should not attempt to get the read url from the settings if it is provided" do
      Tumblr4Rails::Reader.should_not_receive(:ensure_read_url!)
      call_method(default_options.merge(:read_url => "http://www.test.ca"))
    end
  end
  
end