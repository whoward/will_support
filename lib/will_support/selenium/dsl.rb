require_relative 'element'

module WillSupport
  module Selenium
    module DSL
      # waits until the block doesn't raise an exception
      def wait(*args, &block)
        result = nil
        wait_true(*args) { result = block.call; true }
        result
      end

      # waits until the block returns true
      def wait_until_true(*args, &block)
        Selenium::WebDriver::Wait.new(*args).until(&block)
      end
    end
  end
end