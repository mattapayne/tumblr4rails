require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hash Extensions" do
  
  describe "underscore_keys!" do
    
    it "should respond to underscore_keys!" do
      h = {}
      h.should respond_to(:underscore_keys!)
    end
    
    it "should underscore all keys in the hash" do
      h = {:"test-dash" => 12, "monkey-food" => "banana"}
      h.underscore_keys!
      h.should be_key(:test_dash)
      h.should be_key("monkey_food")
      h[:test_dash].should == 12
      h["monkey_food"].should == "banana"
    end
    
  end
   
end

  
describe "URI extensions" do
  
  describe "path_with_querystring" do
    
    it "should respond to path_with_querystring" do
      s = URI.parse("http://www.test.ca")
      s.should respond_to(:path_with_querystring)
    end
  
    it "should return both the path and the querystring" do
      s = "http://www.test.ca/api/json?x=3&y=2"
      uri = URI.parse(s)
      uri.path_with_querystring.should == "/api/json?x=3&y=2"
    end
    
  end
  
end
 