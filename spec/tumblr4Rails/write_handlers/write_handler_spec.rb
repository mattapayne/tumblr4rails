require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::WriteOptions::WriteHandler do
  
  class TestHandler < Tumblr4Rails::WriteOptions::WriteHandler
    
    @@specific_required_params = [:required].freeze
    @@specific_optional_params = [:optional].freeze
    @@validations = {
      :required => Tumblr4Rails::WriteOptions::WriteHandler.not_blank_validator,
      :optional => Tumblr4Rails::WriteOptions::WriteHandler.not_blank_validator,
      :type => lambda {|v| v.to_sym == :test}
    }
    
    @@specific_conversions = {
      :required => lambda {|v| return "Converted"}
    }
    
    def initialize(options)
      super(options)
    end
    
    def post_specific_optional_params
      @@specific_optional_params
    end
      
    def post_specific_required_params
      @@specific_required_params
    end
      
    def post_specific_validations
      @@validations
    end
    
    def post_specific_conversions
      @@specific_conversions
    end
      
  end
  
  def handler(options)
    TestHandler.new(options)
  end
  
  def create_options(other={})
    {:type => :test, :required => "required", :optional => "optional", 
      :email => "test@test.ca", :password => "dfsdfd",
      :write_url => "http://www,test.ca"}.merge(other)
  end
  
  def create_options_except(*exclude)
    exclude = exclude.flatten
    create_options.reject {|k, v| exclude.include?(k)}
  end
  
  describe "cleanse!" do
    
    it "should remove entries that have nil values" do
      h = handler(create_options(:optional => nil))
      result = h.process!
      result.should_not be_key(:optional)
    end
    
    it "should remove all entries that have empty values" do
      h = handler(create_options(:optional => ""))
      result = h.process!
      result.should_not be_key(:optional)
    end
    
    it "should remove all entries that are not a part of the allowed set of params" do
      h = handler(create_options(:abc => "abc", :def => "def"))
      result = h.process!
      result.should_not be_key(:abc)
      result.should_not be_key(:def)
    end
    
  end
  
  describe "ensure_required!" do
    
    it "should raise an exception if one of the required params is missing" do
      h = handler(create_options_except(:type))
      lambda {h.process!}.should raise_error
    end
    
    it "should not raise an exception if all params are present" do
      h = handler(create_options)
      lambda {h.process!}.should_not raise_error
    end
    
  end
  
  describe "collecting base and subclass values" do
    
    it %{it should determine that 'all_validations' is the sum of all base validations
        and all subclass validations} do
      h = handler(create_options)
      p = h.send(:all_validations)
      p.should have(12).items
    end
    
    it %{it should determine that 'all_conversions' is the sum of all base conversions
        and all subclass conversions} do
      h = handler(create_options)
      p = h.send(:all_conversions)
      p.should have(4).items
    end
        
    it "should determine that 'all_params' is the sum of all required and optional params" do
      h = handler(create_options)
      p = h.send(:all_params)
      p.should == [:type, :email, :password, :write_url, :required, :generator, 
        :date, :private, :tags, :format, :group, :optional]
    end
    
    it %{should determine that 'all_optional_params' is the sum of base optional 
        params and subclass optional params} do
      h = handler(create_options)
      p = h.send(:all_optional_params)
      p.should == [:generator, :date, :private, :tags, :format, :group, :optional]
    end
    
    it %{should determine that 'all_required_params' is the sum of base required 
        params and subclass required params} do
      h = handler(create_options)
      p = h.send(:all_required_params)
      p.should == [:type, :email, :password, :write_url, :required]
    end
    
  end
  
  describe "validations" do
    
    def validation_call(name, value)
      Tumblr4Rails::WriteOptions::WriteHandler.send(name).call(value)
    end
    
    describe "generator_validator" do
      
      def call(value)
        validation_call(:generator_validator, value)
      end
      
      it "should return true if the generator is not nil" do
        call("fsfffdf").should be_true
      end
      
      it "should return false if the generator is nil" do
        call(nil).should be_false
      end
      
      it "should return false if the generator is blank" do
        call("").should be_false
      end
      
      it "should return false if the generator is too long" do
        call(("X" * 70)).should be_false
      end
      
    end
    
    describe "email_validator" do
      
      def call(value)
        validation_call(:email_validator, value)
      end
      
      it "should return false if the email is nil" do
        call(nil).should be_false
      end
      
      it "should return false if the email is blank" do
        call("").should be_false
      end
      
      it "should return false if the email is invalid" do
        call("sdfsdfsd").should be_false
      end
      
      it "should return true if the email is valid" do
        call("test@test.ca").should be_true
      end
      
    end
    
    describe "url_validator" do
      
      def call(value)
        validation_call(:url_validator, value)
      end
      
      it "should return true if the url is valid" do
        call("http://www.test.ca").should be_true
      end
      
      it "should return false if the url is not valid" do
        call("sdfsdff").should be_false
      end
      
      it "should return false if the url is nil" do
        call(nil).should be_false
      end
      
      it "should return false if the url is blank" do
        call("").should be_false
      end
      
    end
    
    describe "not_blank_validator" do
      
      def call(value)
        validation_call(:not_blank_validator, value)
      end
      
      it "should return true if the value is not blank" do
        call("Test").should be_true
      end
      
      it "should return false if the value is blank" do
        call("").should be_false
      end
      
    end
    
    describe "group_validator" do
      
      def call(value)
        validation_call(:group_validator, value)
      end
      
      it "should return true if the value is a properly formatted url" do
        call("http://somegroup.tumblr.com").should be_true
      end
      
      it "should return true if the value is a number" do
        call(43543435).should be_true
      end
      
      it "should return true if the value is a string but still a number" do
        call("4355443").should be_true
      end
      
      it "should return false if the value is not a valid url or number" do
        call("gsdgsdgsdg").should be_false
      end
      
      it "should return false if the value is nil" do
        call(nil).should be_false
      end
      
      it "should return false if the value is blank" do
        call("").should be_false
      end
      
    end
    
    describe "private_validator" do
      
      def call(value)
        validation_call(:private_validator, value)
      end
      
      it "should return true if the value is 1" do
        call("1").should be_true
      end
      
      it "should return true if the value is 0" do
        call("0").should be_true
      end
      
      it "should return false if the value is not 1 or 0" do
        call("fdf").should be_false
      end
      
      it "should return false if the value is nil" do
        call(nil).should be_false
      end
      
      it "should return false if the value is blank" do
        call("").should be_false
      end
      
    end
    
    describe "format_validator" do
      
      def call(value)
        validation_call(:format_validator, value)
      end
      
      it "should return true if the value is html" do
        call("html").should be_true
      end
      
      it "should retun true if the value is markdown" do
        call("markdown").should be_true
      end
      
      it "should return true if the value is HTML" do
        call("HTML").should be_true
      end
      
      it "should retun true if the value is MARKDOWN" do
        call("MARKDOWN").should be_true
      end
      
      it "should return false if the value is neither html or markdown" do
        call("ddfsdf").should be_false
      end
      
      it "should return false if the value is nil" do
        call(nil).should be_false
      end
      
      it "should return false if the value is blank" do
        call("").should be_false
      end
      
    end
    
  end
  
  describe "conversions" do
    
    def converter_call(name, value)
      Tumblr4Rails::WriteOptions::WriteHandler.send(name).call(value)
    end
    
    describe "date_converter" do
      
      def call(value)
        converter_call(:date_converter, value)
      end
     
      it "should convert a date object to a properly formatted string" do
        d = Date.today
        expected = d.strftime(Tumblr4Rails::WriteOptions::WriteHandler::DATE_FORMAT)
        call(d).should == expected
      end
     
      it "should convert a datetime object to a properly formatted string" do
        d = DateTime.now
        expected = d.strftime(Tumblr4Rails::WriteOptions::WriteHandler::DATE_FORMAT)
        call(d).should == expected
      end
     
    end
    
    describe "format converter" do
      
      def call(value)
        converter_call(:format_converter, value)
      end
      
      it "should downcase an uppercase string" do
        call("TEST").should == "test"
      end
      
      it "should do nothing to a downcased string" do
        call("test").should == "test"
      end
      
      it "should return nil if passed nil" do
        call(nil).should be_nil
      end
      
    end
    
    describe "private_converter" do
      
      def call(value)
        converter_call(:private_converter, value)
      end
      
      it "should convert false to 0" do
        call(false).should == "0"
      end
      
      it "should convert true to 1" do
        call(true).should == "1"
      end
      
      it "should return 0 if passed 0" do
        call("0").should == "0"
      end
      
      it "should return 1 if passed one" do
        call("1").should == "1"
      end
      
    end
    
    it "should use class-specific conversions as well as base conversions" do
      h = handler(create_options(:date => Date.today, :private => true))
      result = h.process!
      result[:date].should be_is_a(String)
      result[:private].should == "1"
      result[:required].should == "Converted"
    end
    
  end
  
  describe "process!" do
    
    def create_handler
      handler(create_options)
    end
    
    it "should call cleanse!" do
      h = create_handler
      h.should_receive(:cleanse!)
      h.process!
    end
    
    it "should call ensure_required!" do
      h = create_handler
      h.should_receive(:ensure_required!)
      h.process!
    end
    
    it "should call convert_values!" do
      h = create_handler
      h.should_receive(:convert_values!)
      h.process!
    end
    
    it "should call validate_values!" do
      h = create_handler
      h.should_receive(:validate_values!)
      h.process!
    end
    
  end
  
end