# frozen_string_literal: true

module Magento
  module Params
    class CreateProductLink < Dry::Struct
      LinkType = Type::String.enum(
        'related',
        'upsell',
        'crosssell',
        'associated'
      )

      attribute :link_type,           LinkType
      attribute :linked_product_sku,  Type::String
      attribute :linked_product_type, Magento::Params::CreateProduct::ProductTypes
      attribute :position,            Type::Integer
      attribute :sku,                 Type::String

      def to_h
        {
          link_type: link_type,
          linked_product_sku: linked_product_sku,
          linked_product_type: linked_product_type,
          position: position,
          sku: sku
        }
      end
    end
  end
end
