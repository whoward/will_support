# frozen_string_literal: true

require 'forwardable'

module WillSupport
  module Selenium
    class Element
      extend Forwardable

      def_delegators :fetch!, :click, :text, :send_keys, :clear

      def initialize(webdriver, type, value)
        @webdriver = webdriver
        @type = type
        @value = value
      end

      def fetch!
        webdriver.find_element(type, value)
      end

      private

      attr_reader :webdriver, :type, :value
    end
  end
end
