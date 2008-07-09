require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::ConversationLine do
  
  it "should include the Tumblr4Rails::ModelMethods module" do
    Tumblr4Rails::ConversationLine.included_modules.should be_include(Tumblr4Rails::ModelMethods)
  end
  
end
