require File.dirname(__FILE__) + '/../../spec_helper'

describe "Tumblr4Rails::AudioPost" do
  
  describe "get" do
    
    it "should delegate the work to the Tumblr4Rails::Tumblr class when get is called" do
      Tumblr4Rails::Tumblr.should_receive(:audio_posts)
      Tumblr4Rails::AudioPost.get
    end
  
    it "should pass additional options to the Tumblr4Rails::Tumblr class when get is called" do
      Tumblr4Rails::Tumblr.should_receive(:audio_posts).with(hash_including({:id => "12"}))
      Tumblr4Rails::AudioPost.get({:id => "12"})
    end

  end
  
  describe "save/save!" do
    
    def get_upload
      upload = @post.send(:upload_data)
      @post.stub!(:upload_data).and_return(upload)
      upload
    end
    
    before(:each) do
      @post = Tumblr4Rails::AudioPost.new(:filename => "test.mp3", :data => "sdffsd")
      @resp = create_mock_write_response
    end
    
    it "should raise an exception if the file name is blank" do
      @post.filename = ""
      lambda {
        @p1.save!
      }.should raise_error
    end
    
    it "should raise an exception if the data is blank" do
      @post.data = nil
      lambda {
        @p1.save!
      }.should raise_error
    end
    
    it "should delegate the save to the Tumblr class" do
      upload = get_upload
      Tumblr4Rails::Tumblr.should_receive(:create_audio_post).
        with(upload, @post.caption, {}).and_return(@resp)
      @post.save!
    end
    
    it "should include any provided optional params" do
      upload = get_upload
      Tumblr4Rails::Tumblr.should_receive(:create_audio_post).
        with(upload, @post.caption, hash_including(:generator => "Test")).and_return(@resp)
      @post.save!(:generator => "Test")
    end
  
  end
  
end