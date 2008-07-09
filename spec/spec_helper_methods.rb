module SpecHelperMethods
  
  def finders
    [:regular_posts, :photo_posts, :quote_posts, :link_posts, 
      :conversation_posts, :audio_posts, :video_posts, :all_posts ]
  end
  
  def posts_hash
    {
      :tumblelog => tumblelog_hash,
      :posts => [post_hash, post_hash]
    }
  end
  
  def tumblelog_hash
    {:name=>"ggdggf", :timezone=>"US/Eastern", :title=>"dffgdf"}
  end
  
  def feeds_hash
    {:feeds => [feed_hash, feed_hash]}
  end
  
  def feed_hash
    {
      :id=>"4355435", :url=>"http://stuff.com", 
      :"import-type"=>"regular-no-title", :"next-update-in-seconds"=>"850", 
      :title=>"Something", :"error-text"=>"true"
    }
  end
  
  def post_hash
    {
      :id=>"67675675", :url=>"http://test.tumblr.com/post/54554",
      :post_type=>"link", :date_gmt=>"2008-06-17 05:46:07 GMT", 
      :date=>"Tue, 17 Jun 2008 01:46:07", :unix_timestamp=>"1213681567", 
      :bookmarklet=>"true"
    }
  end
      
  def photo_url_hash
    {:"max-size" => "500px"}
  end
  
  def photo_urls_hash
    {:photo_urls => [photo_url_hash, photo_url_hash]}
  end
    
  def conversation_hash
    {:name => "Me", :label => "Me:"}
  end
  
  def conversation_lines_hash
    {:conversation_lines => [conversation_hash, conversation_hash]}
  end
  
  def create_mock_http_response
    mock_http_response = mock("Response")
    mock_http_response.stub!(:code).and_return("200")
    mock_http_response.stub!(:message).and_return("OK")
    mock_http_response.stub!(:body).and_return(regular_posts_xml) 
    mock_http_response  
  end

  def configure_tumblr_for_application_requests
    Tumblr4Rails.configure do |s|
      s.request_type = Tumblr4Rails::RequestType.application
      s.email = "test@test.ca"
      s.password = "dfdfsff"
      s.read_url = "http://www.something.something.com"
    end
  end

  def configure_tumblr_for_request_requests
    Tumblr4Rails.configure do |s|
      s.request_type = Tumblr4Rails::RequestType.request
    end
  end

  def regular_posts_xml
    @regular_posts ||= load_file("regular_posts.xml")
  end

  def conversation_posts_xml
    @conversation_posts ||= load_file("conversation_posts.xml")
  end

  def photo_posts_xml
    @photo_posts ||= load_file("photo_posts.xml")
  end

  def audio_posts_xml
    @audio_posts ||= load_file("audio_posts.xml")
  end

  def video_posts_xml
    @video_posts ||= load_file("video_posts.xml")
  end

  def quote_posts_xml
    @quote_posts ||= load_file("quote_posts.xml")
  end

  def link_posts_xml
    @link_posts ||= load_file("link_posts.xml")
  end

  def load_file(name)
    file_name = File.join(File.dirname(__FILE__), name)
    f = File.open(file_name, "r")
    str = f.read
    return str
  ensure
    f.close
  end
  
end
