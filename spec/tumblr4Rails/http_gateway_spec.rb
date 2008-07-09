require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::HttpGateway do
  
  GET_URL = "http://mpayne.tumblr.com/api/read?type=regular"
  POST_URL = "http://tumblr.com/api/write"
  
  def post_data_args
    {:email => "someemail@test.ca", :password => "XXXX", :some_other_arg => "blah"}
  end
  
  before(:each) do
    @logger = mock("Logger")
    @logger.stub!(:info)
    Tumblr4Rails::HttpGateway.logger = @logger
    @gate = Tumblr4Rails::HttpGateway.new
    @resp = mock("Response")
    @resp.stub!(:code).and_return("200")
    @resp.stub!(:message).and_return("OK")
    @resp.stub!(:body).and_return("gdfgdfgdfgdfgfgdgdf")
  end
  
  it "should respond_to? logger=" do
    Tumblr4Rails::HttpGateway.should respond_to(:logger=)
  end
  
  it "should call request with proper args when get is called" do
    @gate.should_receive(:request).with(:get, GET_URL)
    @gate.get(GET_URL)
  end
  
  it "should call request with proper args when post is called" do
    @gate.should_receive(:request).with(:post, POST_URL, post_data_args)
    @gate.post(POST_URL, post_data_args)
  end
  
  it "should raise an exception if post data is empty" do
    lambda {
      @gate.post(POST_URL, {})
    }.should raise_error
  end
  
  it "should raise an exception if post data is nil" do
    lambda {
      @gate.post(POST_URL, nil)
    }.should raise_error
  end
  
  it "should use the Net::HTTP::Post class to post" do
    post = Net::HTTP::Post.new(URI.parse(POST_URL).path)
    Net::HTTP.stub!(:start).and_return(@resp)
    Net::HTTP::Post.should_receive(:new).with(URI.parse(POST_URL).path).and_return(post)
    @gate.post(POST_URL, post_data_args)
  end
  
  it "should use the Net::HTTP::Get class to get" do
    get = Net::HTTP::Get.new(URI.parse(GET_URL).path_with_querystring)
    Net::HTTP.stub!(:start).and_return(@resp)
    Net::HTTP::Get.should_receive(:new).with(URI.parse(GET_URL).path_with_querystring).and_return(get)
    @gate.get(GET_URL)
  end
  
  it "should pass the URI path and query string for GET requests" do
    Net::HTTP.stub!(:start).and_return(@resp)
    url = URI.parse(GET_URL)
    URI.stub!(:parse).and_return(url)
    url.should_receive(:path_with_querystring).and_return("/api/read?type=regular")
    @gate.get(GET_URL)
  end
  
end