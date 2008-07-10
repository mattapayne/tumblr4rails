require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::ModelMethods do
  
  class TestPost
    
    include Tumblr4Rails::ModelMethods
    @@attr_accessors = [:name, :age]
    attr_reader :phone, :fax, :nicknames
    @@attr_map = {:full_name => :name, :person_age => :age}
    
    def public_has?(key, atts, type=Array)
      has?(key, atts, type)
    end
    
    private
    
    def attr_accessors
      @@attr_accessors
    end
    
    def attribute_map
      @@attr_map
    end
    
    def after_initialized(attributes)
      @nicknames = attributes[:nicknames].inject([]) {|arr, nn| 
        arr << nn.upcase; arr} if has?(:nicknames, attributes)
    end
    
  end
  
  it "should set the post to readonly = false if readonly does not exist in the hash of attributes" do
    post = TestPost.new({:full_name=>"matt"})
    post.should_not be_readonly
  end
  
  it "should set the post to readonly = false if readonly exists in the hash of attributes and is false" do
    post = TestPost.new({:full_name=>"matt", :readonly=>false})
    post.should_not be_readonly
  end
  
  it "should set the post to readonly if readonly is in the hash of attributes and is true" do
    post = TestPost.new({:full_name=>"matt", :readonly=>true})
    post.should be_readonly
  end
  
  describe "has?" do
    
    before(:each) do
      @post = TestPost.new
    end
    
    it "should return false if the hash does not contain the supplied key" do
      opts = {:blah => 1}
      @post.public_has?(:test, opts).should be_false
    end
    
    it "should return false if the hash contains the supplied key, but the type is wrong" do
      opts = {:test => ["monkey", "butler"]}
      @post.public_has?(:test, opts, Hash).should be_false
    end
    
    it "should return true if the hash contains the supplied key and the type is correct" do
      opts = {:test => ["monkey", "butler"]}
      @post.public_has?(:test, opts, Array).should be_true
    end
    
  end
  
  describe "initialize_attributes" do
    
    before(:each) do
      @attrs = {"full_name" => "Matt Payne", :person_age => 12}
    end
    
    it "should call symbolize_keys! on the attributes hash" do
      symbolized = @attrs.symbolize_keys!
      @attrs.should_receive(:symbolize_keys!).and_return(symbolized)
      post = TestPost.new(@attrs)
    end
    
    it "should set any instance variable that matches in the hash" do
      post = TestPost.new(@attrs)
      post.name.should == "Matt Payne"
      post.age.should == 12
      post.phone.should be_nil
    end
    
    it "should map hash keys to variables" do
      post = TestPost.new(@attrs)
      post.should_not respond_to(:full_name)
      post.should_not respond_to(:person_age)
      post.name.should == "Matt Payne"
      post.age.should == 12
    end
    
  end
  
  describe "create_accessors" do
    
    it "should create only readers if the object is readonly" do
      post = TestPost.new({:readonly=>true})
      [:name, :age].each do |accessor|
        post.should respond_to(accessor)
        post.should_not respond_to("#{accessor}=".to_sym)
      end
    end
    
    it "should create readers and writers if the object is not readonly" do
      post = TestPost.new
      [:name, :age].each do |accessor|
        post.should respond_to(accessor)
        post.should respond_to("#{accessor}=".to_sym)
      end
    end
    
  end
  
  describe "remove_accessors" do
    
    it "should remove all setters" do
      post = TestPost.new
      [:name, :age].each do |accessor|
        post.should respond_to(accessor)
        post.should respond_to("#{accessor}=".to_sym)
      end
      post.send(:remove_accessors)
      [:name, :age].each do |accessor|
        post.should_not respond_to("#{accessor}=".to_sym)
      end
    end
  end
  
end