require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::WriteOptions::QuotePostHandler do
  
  def handler(options)
    Tumblr4Rails::WriteOptions::QuotePostHandler.new(options)
  end
  
  def create_options(other={})
    {:type => :quote, :quote => "fsdf", 
      :source => "test", :email => "test@test.ca", :password => "dfsdfd",
      :write_url => "http://www,test.ca"}.merge(other)
  end
  
  def create_options_except(*args)
    args = args.flatten
    create_options.reject {|k,v| args.include?(k)}
  end
  
  it "should remove any entries with nil values" do
    options = create_options(:source => nil)
    h = handler(options)
    result = h.process!
    result.should have(5).items
    result[:source].should be_nil
  end
  
  it "should remove any entries with blank values" do
    options = create_options(:source => "")
    h = handler(options)
    result = h.process!
    result.should have(5).items
    result[:source].should be_nil
  end
  
  it "should remove any entries that do not belong" do
    options = create_options(:xxx => "dfdsf")
    h = handler(options)
    result = h.process!
    result.should have(6).items
    result[:xxx].should be_nil
  end
  
  it "should raise an exception if the quote param is not present" do
    options = create_options_except(:quote)
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
  
  it "should raise an exception if the quote param is nil" do
    options = create_options(:quote => nil)
    lambda {handler(options).process!}.should raise_error
  end
  
  it "should not remove the source param if it has a value" do
    options = create_options
    h = handler(options)
    result = h.process!
    result.should have(6).items
    result[:source].should_not be_nil
  end
  
  it "should not raise an exception if the caption param is not provided (optional)" do
    options = create_options_except(:source)
    lambda {handler(options).process!}.should_not raise_error
  end
  
  it "should keep any optional params as long as they have values" do
    options = create_options(:private => true, :tags => "fdsfd", :date => Date.today,
      :format => "html", :group => 3434243, :generator => "ffasdf")
    h = handler(options)
    result = h.process!
    result[:private].should_not be_nil
    result[:tags].should_not be_nil
    result[:date].should_not be_nil
    result[:format].should_not be_nil
    result[:group].should_not be_nil
    result[:generator].should_not be_nil
  end
  
end