require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::Tumblelog do
  
  it "should include the Tumblr4Rails::ModelMethods module" do
    Tumblr4Rails::Tumblelog.included_modules.should be_include(Tumblr4Rails::ModelMethods)
  end
  
  it "should be readonly" do
    log = Tumblr4Rails::Tumblelog.new
    log.should be_readonly
  end
  
  describe "after_initialized" do
        
    it "should not proceed if the attributes hash is blank" do
      feeds = feeds_hash
      feeds.should_receive(:blank?).at_least(1).times.and_return(true)
      tumblelog = Tumblr4Rails::Tumblelog.new(feeds)
      tumblelog.feeds.should be_nil
    end
    
    it "should populate the feeds if they are present" do
      tumblelog = Tumblr4Rails::Tumblelog.new(feeds_hash)
      tumblelog.feeds.should have(2).items
    end 
    
  end
  
end