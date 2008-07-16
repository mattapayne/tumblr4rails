$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'version'
require 'provided_methods'
require 'pseudo_dbc'
require 'rfc822'
require 'multipart_http'
require 'http'
require 'http_gateway'

