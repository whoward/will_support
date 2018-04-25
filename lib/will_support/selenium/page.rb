# frozen_string_literal: true

require 'nokogiri'
require 'selenium-webdriver'
require_relative 'selector'

module WillSupport
  module Selenium
    class Page
      include DSL

      def self.inherited(base)
        base.extend(ClassMethods)
      end

      def initialize(webdriver)
        @webdriver = webdriver
      end

      def present?
        element(:presence_finder).fetch!
        true
      rescue ::Selenium::WebDriver::Error::NoSuchElementError, KeyError
        false
      end

      def parser
        if self.class.constants.include?(:Parser)
          self.class.const_get(:Parser).parse(webdriver.page_source)
        else
          Nokogiri::HTML::Document.parse(webdriver.page_source)
        end
      end

      def page_name
        self.class.name
      end

      private

      attr_reader :webdriver

      def element(name)
        selector(name).new(webdriver)
      end

      def selector(name)
        self.class.selectors.fetch(name) { raise KeyError, "undefined selector #{name} for page #{page_name}" }
      end

      module ClassMethods
        def selectors
          @selectors ||= {}
        end

        def element(name, *args, &block)
          raise "an element named #{name} is already defined" if selectors.key?(name)
          selectors[name] = Selector.new(*args, &block)
          define_method(name) { element(name) }
        end

        def elements(name, *args, &block)
          # TODO: implement me
        end

        def presence_finder(*args, &block)
          element(:presence_finder, *args, &block)
        end

        def parser(&block)
          const_set(:Parser, Class.new(Nokogiri::HTML::Document)) unless constants.include?(:Parser)

          parser = const_get(:Parser)

          parser.class_eval(&block)

          parser
        end
      end
    end
  end
end
