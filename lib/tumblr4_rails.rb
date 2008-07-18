$:.unshift(File.dirname(__FILE__) + "/tumblr4rails") unless
$:.include?(File.dirname(__FILE__) + "/tumblr4rails") || 
  $:.include?(File.expand_path(File.dirname(__FILE__) + "/tumblr4rails"))

require 'patches/patches'
require 'utility/utilities'
require 'upload'
require 'post_type'
require 'models/models'
require 'write_handlers/write_handlers'
require 'read_handlers/read_handlers'
require 'response'
require 'upload_permission'
require 'request_type'
require 'xml_processing/xml_processing'
require 'converter'
require 'config'
require 'reader'
require 'writer'
require 'tumblr'
require 'tumblr4rails'