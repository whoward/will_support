# frozen_string_literal: true

require_relative 'element'

module WillSupport
  module Selenium
    class Selector
      def initialize(css: nil, xpath: nil, id: nil)
        @type, @value =
          if css
            [:css, css]
          elsif xpath
            [:xpath, xpath]
          elsif id
            [:id, id]
          else
            raise ArgumentError, 'at least one of :css, :xpath, or :id must be specified'
          end
      end

      def new(webdriver)
        Element.new(webdriver, type, value)
      end

      private

      attr_reader :type, :value
    end
  end
end
