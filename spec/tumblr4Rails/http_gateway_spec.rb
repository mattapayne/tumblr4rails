require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::HttpGateway do
  
  GET_URL = "http://mpayne.tumblr.com/api/read?type=regular"
  POST_URL = "http://tumblr.com/api/write"
  
  def stub_http
    URI.stub!(:parse).and_return(@uri)
    http = mock("HTTP")
    @gw.stub!(:http).and_return(http)
    http
  end
  
  before(:each) do
    @uri = URI.parse("http://www.test.ca/api/write")
    @gw = Tumblr4Rails::HttpGateway.new
  end
  
  it "should raise an exception in get_posts if the url provided is blank" do
    lambda {
      @gw.get_posts("")
    }.should raise_error
  end
  
  it "should raise an exception in post_new_post if the url provided is blank" do
    lambda {
      @gw.post_new_post(nil, {:test => "test"})
    }.should raise_error
  end
  
  it "should raise an exception in post_new_post if the data provided are blank" do
    lambda {
      @gw.post_new_post("url", {})
    }.should raise_error
  end
  
  it "should raise an exception in execute_query if the url provided is blank" do
    lambda {
      @gw.execute_query(nil, {:test => "test"})
    }.should raise_error
  end
  
  it "should raise an exception in execute_query if the args provided are blank" do
    lambda {
      @gw.execute_query("url", {})
    }.should raise_error
  end
  
  it "should call post on the http object if the request method is post" do
    http = stub_http
    http.should_receive(:post).with(@uri, 
      hash_including(:test => 1), false).and_return(create_mock_authenticated_response)
    @gw.execute_query("http://www.test.ca/api/write", {:test => 1})
  end
  
  it "should call get on the http object if the request method is get" do
    http = stub_http
    http.should_receive(:get).with(@uri).and_return(create_mock_read_response)
    @gw.get_posts("http://www.test.ca/api/write")
  end
  
end