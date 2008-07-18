require File.dirname(__FILE__) + '/../../spec_helper'

describe "Tumblr4Rails::PhotoPost" do
    
  describe "general" do
    
    before(:each) do
      @post = Tumblr4Rails::PhotoPost.new
    end
    
    it "should freeze the collection of photo post urls when new" do
      @post.urls.should be_frozen
    end
  
    it "should be multipart if data is not blank and source is blank" do
      @post.data = "sdfdfsdf"
      @post.source = nil
      @post.send(:multipart?).should be_true
    end
  
    it "should not be multipart if data is blank and source is not blank" do
      @post.data = ""
      @post.source = "sadasdsd"
      @post.send(:multipart?).should be_false
    end
    
    it "should not be multipart if both data and source are not blank (ie: default to source)" do
      @post.data = "vsddf"
      @post.source = "sadasdsd"
      @post.send(:multipart?).should be_false
    end
  
  end
      
  describe "get" do
    
    it "should delegate the work to the Tumblr4Rails::Tumblr class when get is called" do
      Tumblr4Rails::Tumblr.should_receive(:photo_posts)
      Tumblr4Rails::PhotoPost.get
    end
  
    it "should pass additional options to the Tumblr4Rails::Tumblr class when get is called" do
      Tumblr4Rails::Tumblr.should_receive(:photo_posts).with(hash_including({:id => "12"}))
      Tumblr4Rails::PhotoPost.get({:id => "12"})
    end
    
  end
  
  describe "save/save!" do
    
    before(:each) do
      @resp = create_mock_write_response
    end
    
    describe "saving an uploaded photo" do
      
      def get_upload
        upload = @post.send(:upload_data)
        @post.stub!(:upload_data).and_return(upload)
        upload
      end
    
      before(:each) do
        @post = Tumblr4Rails::PhotoPost.new(:filename => "test.jpeg", 
          :data => "dffsdffsdf", :caption => "Test", 
          :"click-through-url" => "http://test.ca")
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
        Tumblr4Rails::Tumblr.should_receive(:create_photo_post).
          with(upload, @post.caption, @post.click_through_url, {}).and_return(@resp)
        @post.save!
      end
      
      it "should include any optional params provided" do
        upload = get_upload
        Tumblr4Rails::Tumblr.should_receive(:create_photo_post).
          with(upload, @post.caption, @post.click_through_url, 
          hash_including(:generator => "Test")).and_return(@resp)
        @post.save!(:generator => "Test")
      end
      
    end
    
    describe "saving a linked photo" do
      
      before(:each) do
        @post = Tumblr4Rails::PhotoPost.new(:source => "http://www.test.ca/1.gif", 
          :caption => "Test", :"click-through-url" => "http://test.ca")
      end
      
      it "should delegate the save to the Tumblr4Rails::Tumblr class" do
        Tumblr4Rails::Tumblr.should_receive(:create_photo_post).
          with(@post.source, @post.caption, @post.click_through_url, {}).
          and_return(@resp)
        @post.save!
      end
      
      it "should include and optional params provided" do
        Tumblr4Rails::Tumblr.should_receive(:create_photo_post).
          with(@post.source, @post.caption, @post.click_through_url,
          hash_including(:generator => "Test")).and_return(@resp)
        @post.save!(:generator => "Test")
      end
      
    end
    
  end
  
  describe "after_initialized" do
    
    it "should not proceed if the attributes are blank" do
      opts = photo_urls_hash
      opts.should_receive(:blank?).at_least(1).times.and_return(true)
      post = Tumblr4Rails::PhotoPost.new(opts)
      post.urls.should == []
    end
    
    it "should freeze the post urls after processing them" do
      post = Tumblr4Rails::PhotoPost.new(photo_urls_hash)
      post.urls.should be_frozen
    end
    
    it "should populate the urls collection if the attributes are not blank" do
      post = Tumblr4Rails::PhotoPost.new(photo_urls_hash)
      post.urls.should have(2).items
    end
    
  end
  
end