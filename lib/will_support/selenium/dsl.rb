# frozen_string_literal: true

require_relative 'element'

module WillSupport
  module Selenium
    # TODO: this doesn't seem to be used anywhere - we need to include it, possibly in Page or Element
    module DSL
      # waits until the block doesn't raise an exception
      def wait(*args)
        result = nil
        wait_true(*args) do
          result = yield
          true
        end
        result
      end

      # waits until the block returns true
      def wait_until_true(*args, &block)
        Selenium::WebDriver::Wait.new(*args).until(&block)
      end

      # gives you the current location of the web browser
      def current_url
        webdriver.current_url
      end
    end
  end
end
