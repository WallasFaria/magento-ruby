# frozen_string_literal: true

module Magento
  module Params
    class CreateCategoria < Dry::Struct
      attribute :name,      Type::String
      attribute :parent_id, Type::String.optional
      attribute :path,      Type::String.optional
      attribute :is_active, Type::Bool.default(true)

      def to_h
        {
          "name": name,
          "parent_id": parent_id,
          "is_active": is_active,
          "path": path
        }
      end
    end
  end
end
