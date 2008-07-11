require File.dirname(__FILE__) + '/../spec_helper'

describe "Tumblr4Rails::TumblrReader, Tumblr4Rails::TumblrWriter" do
  
  def reader_metaclass
    class << Tumblr4Rails::TumblrReader; self; end
  end
  
  def writer_metaclass
    class << Tumblr4Rails::TumblrWriter; self; end
  end
  
  it "should extend the required modules" do
    reader_metaclass.included_modules.should be_include(Tumblr4Rails::Read)
    writer_metaclass.included_modules.should be_include(Tumblr4Rails::Write)
  end

end
