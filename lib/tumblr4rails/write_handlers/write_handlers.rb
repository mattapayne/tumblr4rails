$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'write_handler'
require 'audio_post_handler'
require 'conversation_post_handler'
require 'link_post_handler'
require 'photo_post_handler'
require 'quote_post_handler'
require 'regular_post_handler'
require 'video_post_handler'
require 'query_handler'
require 'factory'
