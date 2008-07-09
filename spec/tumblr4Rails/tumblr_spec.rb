require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::Tumblr do
  
  def get_metaclass
    class << Tumblr4Rails::Tumblr; self; end
  end
  
  it "should extend the required modules" do
    get_metaclass.included_modules.should be_include(Tumblr4Rails::Read)
    get_metaclass.included_modules.should be_include(Tumblr4Rails::Write)
  end

end
