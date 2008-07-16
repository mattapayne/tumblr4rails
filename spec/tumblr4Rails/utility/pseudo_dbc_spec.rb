require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::PseudoDbc do
  include Tumblr4Rails::PseudoDbc
  
  describe "pre_ensure" do
    
    it "should raise an exception before evaluating the block if any condition is not met" do
      executed = false
      lambda {
        pre_ensure "message" => (false) do
          executed = true
        end
      }.should raise_error
      executed.should be_false
    end
    
    it "should evaluate the block and not raise an exception if all conditions are met" do
      executed = false
      lambda {
        pre_ensure "message" => (true) do
          executed = true
        end
      }.should_not raise_error
      executed.should be_true
    end
    
  end
  
  describe "post_ensure" do
    
    it "should evaluate the block and then raise an exception if any condition is not met" do
      executed = false
      lambda {
        post_ensure "message" => (false) do
          executed = true
        end
      }.should raise_error
      executed.should be_true
    end
    
    it "should evaluate the block and not raise an exception if all conditions are met" do
      executed = false
      lambda {
        post_ensure "message" => (true) do
          executed = true
        end
      }.should_not raise_error
      executed.should be_true
    end
    
  end
  
end