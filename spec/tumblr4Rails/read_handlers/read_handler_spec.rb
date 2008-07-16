require File.dirname(__FILE__) + '/../../spec_helper'

describe Tumblr4Rails::ReadOptions::ReadHandler do
  
  def create_options(options={})
    {:type => :regular, :start => 0, :num => 10, 
      :read_url => "http://www.google.ca"}.merge(options)
  end
  
  def create_options_except(*args)
    args = args.flatten
    create_options.reject {|k, v| args.include?(k)}
  end
  
  def handler(options)
    Tumblr4Rails::ReadOptions::ReadHandler.new(options)
  end
  
  describe "process!" do
    
    it "should call cleanse!" do
      options = create_options
      h = handler(options)
      h.should_receive(:cleanse!)
      h.process!
    end
    
    it "should call translate_aliases!" do
      options = create_options
      h = handler(options)
      h.should_receive(:translate_aliases!)
      h.process!
    end
    
    it "should call ensure_number! if a num param is given" do
      options = create_options
      h = handler(options)
      h.should_receive(:ensure_number!)
      h.process!
    end
    
    it "should not call ensure_number! if a num parameter is not given" do
      options = create_options_except(:num)
      h = handler(options)
      h.should_not_receive(:ensure_number!)
      h.process!
    end
    
    it "should call ensure_start! if a start param is given" do
      options = create_options
      h = handler(options)
      h.should_receive(:ensure_start!)
      h.process!
    end
    
    it "should not call ensure_start! if a start param is not given" do
      options = create_options_except(:start)
      h = handler(options)
      h.should_not_receive(:ensure_start!)
      h.process!
    end
    
  end
  
  describe "translate_aliases!" do
    
    it "should translate index to start" do
      options = create_options_except(:start).merge(:index => 2)
      options.should_not be_key(:start)
      h = handler(options).process!
      h.should be_key(:start)
      h[:start].should == 2
    end
    
    it "should translate limit to num" do
      options = create_options_except(:num).merge(:limit => 5)
      options.should_not be_key(:num)
      h = handler(options).process!
      h.should be_key(:num)
      h[:num].should == 5
    end
    
  end
  
  describe "ensure_number!" do
  
    it "should set num to 1 if num < 1" do
      options = create_options(:num => -1)
      result = handler(options).process!
      result[:num].should == 1
    end
  
    it "should set num to 50 if num > 50" do
      options = create_options(:num => 60)
      result = handler(options).process!
      result[:num].should == 50
    end
  
    it "should not change num if it is in the allowed range" do
      options = create_options(:num => 15)
      result = handler(options).process!
      result[:num].should == 15
    end
  
  end
  
  describe "ensure_start!" do
  
    it "should set start to 0 if start is < 0" do
      options = create_options(:start => -1)
      result = handler(options).process!
      result[:start].should == 0
    end
  
    it "should not change start if start >= 0" do
      options = create_options(:start => 2)
      result = handler(options).process!
      result[:start].should == 2
    end
  
  end
  
  describe "cleanse!" do
    
    it "should remove entries with blank values" do
      options = create_options(:json => true, :callback => "")
      result = handler(options).process!
      result.should_not be_key(:callback)
      result[:json].should be_true
    end
  
    it "should remove entries with nil values" do
      options = create_options(:json => true, :callback => nil)
      result = handler(options).process!
      result.should_not be_key(:callback)
      result[:json].should be_true
    end
  
    it "should remove all params that do not belong" do
      options = create_options(:xxx => "dfsff")
      result = handler(options).process!
      result.should_not be_key(:xxx)
    end
  
    it "should remove callback if json is not set to true" do
      options = create_options(:callback => "")
      result = handler(options).process!
      result.should_not be_key(:callback)
    end
  
    it "shuld not remove callback if json is set to true" do
      options = create_options(:json => true, :callback => "sdsdff")
      result = handler(options).process!
      result[:callback].should_not be_nil
      result[:json].should be_true
    end
  
    it "should remove start, num and type if id is set" do
      options = create_options(:id => 12)
      result = handler(options).process!
      result.should_not be_key(:type)
      result.should_not be_key(:num)
      result.should_not be_key(:start)
    end
  
    it "should remove type if type is set to :all" do
      options = create_options(:type => :all)
      result = handler(options).process!
      result.should_not be_key(:type)
    end
  
    it "should remove type if type is set to 'all'" do
      options = create_options(:type => "all")
      result = handler(options).process!
      result.should_not be_key(:type)
    end
  
  end
  
end