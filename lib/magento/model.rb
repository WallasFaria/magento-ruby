# frozen_string_literal: true

require 'dry/inflector'

module Magento
  class Model
    class << self
      protected

      def mapHash(klass, values)
        object = klass.new
        values.each do |key, value|
          object.singleton_class.instance_eval { attr_accessor key }
          if value.is_a?(Hash)
            class_name = inflector.camelize(inflector.singularize(key))
            value = mapHash(Object.const_get("Magento::#{class_name}"), value)
          elsif value.is_a?(Array)
            value = mapArray(key, value)
          end
          object.send("#{key}=", value)
        end
        object
      end

      def mapArray(key, values)
        result = []
        values.each do |value|
          if value.is_a?(Hash)
            class_name = inflector.camelize(inflector.singularize(key))
            result << mapHash(Object.const_get("Magento::#{class_name}"), value)
          else
            result << value
          end
        end
        result
      end

      def inflector
        @inflector ||= Dry::Inflector.new
      end
    end
  end
end
