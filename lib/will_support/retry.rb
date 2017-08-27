# frozen_string_literal: true

module WillSupport
  class Retry
    K = -> {}

    attr_reader :attempts, :caught_exceptions, :callbacks, :handlers

    def initialize(attempts: 5, caught_exceptions: StandardError)
      @attempts = attempts
      @caught_exceptions = Array(caught_exceptions)
      @callbacks = []
      @handlers = {}
    end

    def handle(selector, &block)
      handlers[selector] = block
      self
    end

    def after_exception(&block)
      callbacks << block
      self
    end

    def run(&block)
      attempt = 0
      begin
        # this is a very hard method to test when using yield, so we will bypass
        # the rubocop rule for now

        # rubocop:disable Performance/RedundantBlockCall
        block.call
        # rubocop:enable Performance/RedundantBlockCall
      rescue *caught_exceptions => e
        handler_for_exception(e).call

        callbacks.each { |c| c.call(e) }

        attempt += 1

        raise if attempt >= attempts

        retry
      end
    end

    private

    def class_handlers
      handlers.keys.grep(Class)
    end

    def class_handler_for_exception(e)
      ancestors = e.class.ancestors

      matching_key = class_handlers.min_by { |klass| ancestors.index(klass) }

      handlers[matching_key] if matching_key
    end

    def proc_handlers
      handlers.keys.grep(Proc)
    end

    def proc_handler_for_exception(e)
      matching_key = proc_handlers.detect { |proc| proc.call(e) }

      handlers[matching_key] if matching_key
    end

    def handler_for_exception(e)
      proc_handler_for_exception(e) || class_handler_for_exception(e) || K
    end
  end
end
