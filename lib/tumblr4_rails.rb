#Hack URI::HTTP to include a method that gets us both the path and the querystring
#since path_query is private
module URI
  class HTTP < Generic
    def path_with_querystring
      path_query
    end
  end
end

class Hash
    
  def underscore_keys!
    keys.each do |k|
      value = delete(k)
      value.underscore_keys! if value.is_a?(Hash)
      value.each {|v| v.underscore_keys! if v.is_a?(Hash)} if value.is_a?(Array)
      self[k.to_s.underscore] = value
    end
  end
  
  def split_on!(*keys)
    h = {}
    keys.flatten.each { |k| h[k] = delete(k) if key?(k)}
    h
  end
    
end

$:.unshift(File.dirname(__FILE__) + "/tumblr4rails") unless
$:.include?(File.dirname(__FILE__) + "/tumblr4rails") || 
  $:.include?(File.expand_path(File.dirname(__FILE__) + "/tumblr4rails"))

require 'version'
require 'pseudo_dbc'
require 'upload'
require 'models/models'
require 'post_creation_response'
require 'post_type'
require 'rfc822'
require 'upload_permission'
require 'request_type'
require 'tag_handlers'
require 'posts_listener'
require 'converter'
require 'config'
require 'multipart_http'
require 'http'
require 'http_gateway'
require 'read_write_common'
require 'read'
require 'write'
require 'tumblr'
require 'tumblr4rails'