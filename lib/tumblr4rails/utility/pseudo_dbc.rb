module Tumblr4Rails

  module PseudoDbc
    
    private
    
    def pre_ensure(conditions, &block)
      check_conditions(conditions)
      block.call if block_given?
    end
    
    def post_ensure(conditions, &block)
       block.call if block_given?
       check_conditions(conditions)
    end
    
    def check_conditions(conditions)
      errors = conditions.inject([]) {|arr, (msg, cond)| arr << msg unless cond; arr;}
      raise ArgumentError.new(errors.to_sentence) unless errors.empty?
    end

  end

end
