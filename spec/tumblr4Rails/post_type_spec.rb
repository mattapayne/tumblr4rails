require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::PostType do
  
  it "should respond to a number of post types" do
    Tumblr4Rails::PostType.all_post_types.collect {|t| t.name.to_sym}.each do |type|
      Tumblr4Rails::PostType.should respond_to(type)
    end
  end
  
  it "should provide post type names as both a string and a symbol" do
    names = Tumblr4Rails::PostType.post_type_names
    counter = {}
    names.each do |name|
      n = name.to_sym
      if counter.key?(n) then counter[n] += 1
      else
        counter[n] = 1
      end
    end
    Tumblr4Rails::PostType.all_post_types.collect {|t| t.name.to_sym}.each do |type|
      counter[type].should == 2
    end
    
  end
    
end
