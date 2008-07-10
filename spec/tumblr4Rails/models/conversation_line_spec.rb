require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::ConversationLine do
  
  it "should include the Tumblr4Rails::ModelMethods module" do
    Tumblr4Rails::ConversationLine.included_modules.should be_include(Tumblr4Rails::ModelMethods)
  end
  
  it "should be readonly" do
    line = Tumblr4Rails::ConversationLine.new
    line.should be_readonly
  end
  
end
