# frozen_string_literal: true

module Magento
  module Params
    class CreateCustomAttribute
      attr_accessor :code, :value
  
      # @param code: [String]
      # @param value: [String]
      def initialize(code:, value:)
        self.code = code
        self.value = value
      end
  
      def to_h
        {
          "attribute_code": code,
          "value": value
        }
      end
    end
  end
end
