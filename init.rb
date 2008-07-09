require 'tumblr4_rails'
Tumblr4Rails::HttpGateway.logger = RAILS_DEFAULT_LOGGER
ActionController::Base.send(:include, Tumblr4Rails)