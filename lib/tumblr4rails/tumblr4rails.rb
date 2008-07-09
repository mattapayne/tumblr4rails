module Tumblr4Rails
  
  def self.included(klazz)
    klazz.extend(ClassMethods)
  end
  
  def self.configure(&block)
    @@tumblr_config = nil
    raise ArgumentError.new("A block is required.") unless block_given?
    configured = false
    begin
      block.call(configuration)
      if configuration.valid?
        configured = true
      else
        errors = configuration.errors
        raise ArgumentError.new("Tumblr4Rails config is incorrect: #{errors.join(', ')}")
      end
    ensure
      unless configured
        @@tumblr_config = nil
      end
    end
  end
  
  def self.configuration
    @@tumblr_config ||= Tumblr4Rails::Config.new
  end

  module ClassMethods

    def use_tumblr
      include Tumblr4Rails
    end
    
  end
  
end