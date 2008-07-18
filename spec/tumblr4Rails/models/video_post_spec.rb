require File.dirname(__FILE__) + '/../../spec_helper'

describe "Tumblr4Rails::VideoPost" do
  
  before(:each) do
    @post = Tumblr4Rails::VideoPost.new
    @resp = create_mock_write_response
  end
  
  describe "general" do
    
    before(:each) do
      @post = Tumblr4Rails::VideoPost.new
    end
  
    it "should be multipart if data is not blank and embed is blank" do
      @post.data = "sdfdfsdf"
      @post.embed = nil
      @post.send(:multipart?).should be_true
    end
  
    it "should not be multipart if data is blank and embed is not blank" do
      @post.data = ""
      @post.embed = "sadasdsd"
      @post.send(:multipart?).should be_false
    end
    
    it "should not be multipart if both data and embed are not blank (ie: default to embed)" do
      @post.data = "vsddf"
      @post.embed = "sadasdsd"
      @post.send(:multipart?).should be_false
    end
  
  end
  
  describe "get" do
    
    it "should delegate the work to the Tumblr4Rails::Tumblr class when get is called" do
      Tumblr4Rails::Tumblr.should_receive(:video_posts)
      Tumblr4Rails::VideoPost.get
    end
  
    it "should pass additional options to the Tumblr4Rails::Tumblr class when get is called" do
      Tumblr4Rails::Tumblr.should_receive(:video_posts).with(hash_including({:id => "12"}))
      Tumblr4Rails::VideoPost.get({:id => "12"})
    end
    
  end
  
  describe "save/save!" do
    
    before(:each) do
      @resp = create_mock_write_response
    end
    
    describe "saving an uploaded video" do
      
      def get_upload
        upload = @post.send(:upload_data)
        @post.stub!(:upload_data).and_return(upload)
        upload
      end
      
      before(:each) do
        @post = Tumblr4Rails::VideoPost.new(:filename => "test.wmv", 
          :data => "dffsdffsdf", :caption => "Test", 
          :title => "title")
      end
      
      it "should raise an exception if the filename is blank" do
        @post.filename = ""
        lambda {
          @post.save!
        }.should raise_error
      end
      
      it "should raise an exception if the data is blank" do
        @post.data = nil
        lambda {
          @post.save!
        }.should raise_error
      end
      
      it "should delegate the save to the Tumblr4Rails::Tumblr class" do
        upload = get_upload
        Tumblr4Rails::Tumblr.should_receive(:create_video_post).
          with(upload, @post.title, @post.caption, {}).and_return(@resp)
        @post.save!
      end
      
      it "should include any optional params provided" do
        upload = get_upload
        Tumblr4Rails::Tumblr.should_receive(:create_video_post).
          with(upload, @post.title, @post.caption, 
          hash_including(:generator => "Test")).and_return(@resp)
        @post.save!(:generator => "Test")
      end
      
    end
    
    describe "saving an embedded video" do
      
      before(:each) do
        @post = Tumblr4Rails::VideoPost.new(:embed => "http://www.test.ca/1.wmv", 
          :caption => "Test", :title => "title")
      end
      
      it "should delegate the save to the Tumblr4Rails::Tumblr class" do
        Tumblr4Rails::Tumblr.should_receive(:create_video_post).
          with(@post.embed, @post.title, @post.caption, {}).
          and_return(@resp)
        @post.save!
      end
      
      it "should include and optional params provided" do
        Tumblr4Rails::Tumblr.should_receive(:create_video_post).
          with(@post.embed, @post.title, @post.caption,
          hash_including(:generator => "Test")).and_return(@resp)
        @post.save!(:generator => "Test")
      end
      
    end
    
  end
  
end