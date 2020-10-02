# frozen_string_literal: true

module Magento
  module Params
    class CreateCustomAttribute < Dry::Struct
      attribute :code, Type::String
      attribute :value, Type::String

      def to_h
        {
          "attribute_code": code,
          "value": value
        }
      end
    end
  end
end
