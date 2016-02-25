require_relative 'page'

module WillSupport
  module Selenium
    module PageCollection
      def define(name, &block)
        class_name = camelize(name.to_s).to_sym

        unless constants.include?(class_name)
          klass = Class.new(Page)

          const_set class_name, klass

          define_singleton_method(name) { klass }
        end

        klass = const_get(class_name)

        klass.class_eval(&block)
        
        klass
      end
      
      private 
      
      # this is a cheap version of ActiveRecord's camelize function
      def camelize(string)
        string.downcase.capitalize.gsub(/_([a-z])/) {|match| match[1].upcase }
      end
    end
  end
end