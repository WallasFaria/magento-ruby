# frozen_string_literal: true

module Magento
  module Params
    class CreateCategoria < Dry::Struct
      attribute :name,      Type::String
      attribute :parent_id, Type::Integer.optional
      attribute :url,       Type::String.optional.default(nil)
      attribute :is_active, Type::Bool.default(true)

      def to_h
        {
          name: name,
          parent_id: parent_id,
          is_active: is_active,
          custom_attributes: url ? [{attribute_code: 'url_key', value: url }] : nil
        }.compact
      end
    end
  end
end
