require File.dirname(__FILE__) + '/../../spec_helper'

describe "Tumblr4Rails::Post" do
  
  def mock_response(code="201")
    resp = mock("Response")
    resp.stub!(:code).and_return(code)
    resp.stub!(:new_id).and_return("553454")
    resp
  end
  
  before(:each) do
    @post = Tumblr4Rails::Post.new
  end
  
  it "should delegate the work to the Tumblr4Rails::Reader class when get is called" do
    Tumblr4Rails::Reader.should_receive(:all_posts)
    Tumblr4Rails::Post.get
  end
  
  it "should pass additional options to the Tumblr4Rails::Reader class when get is called" do
    Tumblr4Rails::Reader.should_receive(:all_posts).with(hash_including({:num => "12"}))
    Tumblr4Rails::Post.get({:num => "12"})
  end
  
  it "should delegate the work to the Tumblr4Rails::Reader class when get_by_id is called" do
    Tumblr4Rails::Reader.should_receive(:get_by_id).with(1, false, nil)
    Tumblr4Rails::Post.get_by_id(1)
  end
  
  it "should return nil from get_by_id if the id passed in is blank" do
    Tumblr4Rails::Post.get_by_id(nil).should be_nil
  end
  
  it "should call save! from save" do
    @post.should_receive(:save!)
    @post.save
  end
  
  it "should return false from save when save! raises an exception" do
    @post.should_receive(:save!).and_raise(RuntimeError)
    @post.save.should be_false
  end
  
  it "should return true from save when save! does not raise an exception" do
    @post.should_receive(:save!).and_return(mock_response)
    @post.save.should be_true
  end
  
  it "should raise an exception from save! if the class is marked readonly" do
    @post.stub!(:readonly?).and_return(true)
    lambda {@post.save!}.should raise_error
  end
  
  it "should call do_save! from save! if the model is not readonly" do
    @post.should_receive(:do_save!).and_return(mock_response)
    @post.save!
  end
  
  it "should update its tumblr_id and freeze itself if the response code is 201" do
    @post.stub!(:do_save!).and_return(mock_response)
    @post.should_receive(:instance_variable_set).with(:@tumblr_id, "553454")
    @post.should_receive(:freeze)
    @post.save!
  end
  
  it "should not set the tumblr_id on the post if the response code is not 200" do
    @post.stub!(:do_save!).and_return(mock_response("401"))
    @post.should_not_receive(:instance_variable_set)
    @post.save!
  end
  
  it "should not become frozen if the the save is unsuccessful" do
    @post.stub!(:do_save!).and_return(mock_response("401"))
    @post.should_not_receive(:freeze)
    @post.save!
  end
  
  it "should include Tumblr4Rails::ModelMethods" do
    Tumblr4Rails::Post.included_modules.should be_include(Tumblr4Rails::ModelMethods)
  end
  
end