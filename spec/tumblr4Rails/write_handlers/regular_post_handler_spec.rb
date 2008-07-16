require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::WriteOptions::RegularPostHandler do
  
  def handler(options)
    Tumblr4Rails::WriteOptions::RegularPostHandler.new(options)
  end
  
  def create_options(other={})
    {:type => :regular, :title => "Title", 
      :body => "test", :email => "test@test.ca", :password => "dfsdfd",
      :write_url => "http://www,test.ca", :generator => "Gen"}.merge(other)
  end
  
  def create_options_except(*args)
    args = args.flatten
    create_options.reject {|k,v| args.include?(k)}
  end
  
  it "should keep any optional params as long as they have values" do
    options = create_options(:private => true, :tags => "fdsfd", :date => Date.today,
      :format => "html", :group => 3434243)
    h = handler(options)
    result = h.process!
    result[:private].should_not be_nil
    result[:tags].should_not be_nil
    result[:date].should_not be_nil
    result[:format].should_not be_nil
    result[:group].should_not be_nil
    result[:generator].should_not be_nil
  end
  
  it "should remove any entries with nil values" do
    options = create_options(:generator => nil)
    h = handler(options)
    result = h.process!
    result.should have(6).items
    result[:generator].should be_nil
  end
  
  it "should remove any entries with blank values" do
    options = create_options(:generator => "")
    h = handler(options)
    result = h.process!
    result.should have(6).items
    result[:generator].should be_nil
  end
  
  it "should remove any entries that do not belong" do
    options = create_options(:xxx => "dfdsf")
    h = handler(options)
    result = h.process!
    result.should have(7).items
    result[:xxx].should be_nil
  end
  
  it "should raise an exception if the title param is not present" do
    options = create_options_except(:title)
    lambda {handler(options).process!}.should raise_error
  end
  
  it "should raise an exception if the body param is not present" do
    options = create_options_except(:body)
    lambda {handler(options).process!}.should raise_error
  end
  
  it "should raise an exception if the write_url is malformed" do
    options = create_options(:write_url => "dfsdf")
    lambda {handler(options).process!}.should raise_error
  end
  
  it "should raise an exception if email not provided" do
    options = create_options_except(:email)
    lambda {handler(options).process!}.should raise_error
  end
  
  it "should raise an exception if password not provided" do
    options = create_options_except(:password)
    lambda {handler(options).process!}.should raise_error
  end
  
  it "should raise an exception if write_url not provided" do
    options = create_options_except(:write_url)
    lambda {handler(options).process!}.should raise_error
  end
  
  it "should raise an exception if the type is incorrect" do
    options = create_options(:type => :fsddfs)
    lambda {handler(options).process!}.should raise_error
  end
  
end