require File.dirname(__FILE__) + '/../spec_helper'

describe Tumblr4Rails::Converter do

  describe "general usage" do
   
    it "should return nil if the xml passed in is blank" do
      Tumblr4Rails::Converter.convert(nil).should be_nil
      Tumblr4Rails::Converter.convert("").should be_nil
    end
    
    it "should convert the xml into a hash" do
      xml = conversation_posts_xml
      Tumblr4Rails::Converter.send(:cleanup_data!, xml)
      posts = Tumblr4Rails::Converter.send(:parse_data, xml).posts
      posts.should be_is_a(Hash)
    end
  
    it "should return an Tumblr4Rails::Posts object based on the passed in xml" do
      xml = conversation_posts_xml
      Tumblr4Rails::Converter.convert(xml).should be_is_a(Tumblr4Rails::Posts)
    end
    
    it "should replace instances of 'conversation-line' with 'coversation-lines'" do
      xml = conversation_posts_xml
      xml.should =~ /.*<conversation-line.*>(.|\s)*<\/conversation-line>/
      Tumblr4Rails::Converter.send(:cleanup_data!, xml)
      xml.should_not =~ /.*<conversation-line.*>(.|\s)*<\/conversation-line>/
      xml.should =~ /.*<conversation-lines.*>(.|\s)*<\/conversation-lines>/
    end
    
    it "should replace instances of 'photo-url' with 'photo-urls'" do
      xml = photo_posts_xml
      xml.should =~ /<photo-url.*>.*<\/photo-url>/
      Tumblr4Rails::Converter.send(:cleanup_data!, xml)
      xml.should =~ /<photo-urls.*>.*<\/photo-urls>/
      xml.should_not =~ /<photo-url.*>.*<\/photo-url>/
    end
    
    it "should replace instances of 'type=' with 'post-type='" do
      xml = conversation_posts_xml
      xml.should =~ /.*(\s){1,}type=.*/
      Tumblr4Rails::Converter.send(:cleanup_data!, xml)
      xml.should_not =~ /.*(\s){1,}type=.*/
      xml.should =~ /.*(\s){1,}post_type=.*/
    end
    
    it "should replace instances of 'id=' with 'tumblr-id='" do
      xml = conversation_posts_xml
      xml.should =~ /\sid=/
      Tumblr4Rails::Converter.send(:cleanup_data!, xml)
      xml.should_not =~ /\sid=/
      xml.should =~ /\stumblr-id=/
    end
    
    it "should properly handle nested structures" do
      xml = conversation_posts_xml
      result = Tumblr4Rails::Converter.convert(xml)
      result.should have(1).items
      result.should respond_to(:tumblelog)
      result.tumblelog.should respond_to(:feeds)
      result.tumblelog.feeds.should have(1).items
    end
    
  end
  
end
