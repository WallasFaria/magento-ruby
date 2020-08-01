# frozen_string_literal: true

require 'dry/inflector'

module Magento
  class Model
    class << self
      protected

      def map_hash(klass, values)
        object = klass.new
        values.each do |key, value|
          object.singleton_class.instance_eval { attr_accessor key }
          if value.is_a?(Hash)
            class_name = inflector.camelize(inflector.singularize(key))
            value = map_hash(Object.const_get("Magento::#{class_name}"), value)
          elsif value.is_a?(Array)
            value = map_array(key, value)
          end
          object.send("#{key}=", value)
        end
        object
      end

      def map_array(key, values)
        result = []
        values.each do |value|
          if value.is_a?(Hash)
            class_name = inflector.camelize(inflector.singularize(key))
            result << map_hash(Object.const_get("Magento::#{class_name}"), value)
          else
            result << value
          end
        end
        result
      end

      def inflector
        @inflector ||= Dry::Inflector.new
      end

      def request
        @request ||= Request.new
      end
    end
  end
end
