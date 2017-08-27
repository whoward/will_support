# frozen_string_literal: true

module WillSupport
  module Curry
    def curry(method_name)
      if is_a?(Class)
        curry_on_instance(method_name)
      else
        curry_on_singleton(method_name)
      end
    end

    def curry_on_singleton(method_name)
      existing = method(method_name)

      define_singleton_method("uncurried_#{method_name}", &existing)

      define_singleton_method(method_name) do |*args, &block|
        if args.length.positive?
          existing.call(*args, &block)
        else
          existing.curry
        end
      end
    end

    def curry_on_instance(method_name)
      existing = instance_method(method_name)

      define_method("uncurried_#{method_name}") do |*args, &block|
        existing.bind(self).call(*args, &block)
      end

      define_method(method_name) do |*args, &block|
        method = existing.bind(self)

        args.length.positive? ? method.call(*args, &block) : method.curry
      end
    end
  end
end
