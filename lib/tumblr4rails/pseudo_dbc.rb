module Tumblr4Rails

  module PseudoDbc
    
    def pre_ensure(conditions, &block)
      check_conditions(conditions)
      block.call if block_given?
    end
    
    def post_ensure(conditions, &block)
       block.call if block_given?
       check_conditions(conditions)
    end
    
    private
    
    def check_conditions(conditions)
      errors = []
      conditions.each {|msg, condition| errors << msg unless condition}
      raise ArgumentError.new(errors.to_sentence) unless errors.empty?
    end

  end

end
