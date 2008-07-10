require File.dirname(__FILE__) + '/../../spec_helper'

describe "Tumblr4Rails::Tumblelog" do
  
  it "should include the Tumblr4Rails::ModelMethods module" do
    Tumblr4Rails::Tumblelog.included_modules.should be_include(Tumblr4Rails::ModelMethods)
  end
  
  it "should be frozen" do
    log = Tumblr4Rails::Tumblelog.new
    log.should be_frozen
  end
  
  it "should freeze the collection of feeds even when new" do
    log = Tumblr4Rails::Tumblelog.new
    log.feeds.should be_frozen
  end
  
  describe "after_initialized" do
        
    it "should not proceed if the attributes hash is blank" do
      feeds = feeds_hash
      feeds.should_receive(:blank?).at_least(1).times.and_return(true)
      tumblelog = Tumblr4Rails::Tumblelog.new(feeds)
      tumblelog.feeds.should == []
    end
    
    it "should freeze the feeds after processing them" do
      tumblelog = Tumblr4Rails::Tumblelog.new(feeds_hash)
      tumblelog.feeds.should be_frozen
    end
    
    it "should populate the feeds if they are present" do
      tumblelog = Tumblr4Rails::Tumblelog.new(feeds_hash)
      tumblelog.feeds.should have(2).items
    end 
    
  end
  
end