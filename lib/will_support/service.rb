require 'deterministic'

module WillSupport
  module Service
    Error = Class.new(StandardError)
    
    module Object
      def self.included(base)
        base.send(:include, Deterministic::Prelude::Result)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def service_method(method_name, &block)
          define_method(method_name, &block) if block_given?
          
          existing = instance_method(method_name)
          
          define_method(method_name) do |*args, &inner_block|
            value = existing.bind(self).call(*args, &inner_block)
            
            return value if value.is_a?(Deterministic::Result)
            
            if value
              Success(value)
            else
              Failure(value)
            end
          end
          
          define_method("#{method_name}!") do
            result = send(method_name)
            
            if result.success?
              result
            else
              raise Error, result
            end
          end
          
          method_name
        end
      end
    end
  end
end