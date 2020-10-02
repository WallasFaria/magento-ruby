require_relative 'create_image'
require_relative 'create_custom_attribute'

module Magento
  module Params
    class CreateProduct < Dry::Struct
      ProductTypes = Type::String.default('simple'.freeze).enum(
        'simple',
        'bundle',
        'configurable',
        'downloadable',
        'grouped',
        'Virtual'
      )

      Visibilities = Type::String.default('catalog_and_search'.freeze).enum(
        'not_visible_individually' => 1,
        'catalog' => 1,
        'search' => 3,
        'catalog_and_search' => 4
      )

      Statuses = Type::String.default('enabled'.freeze).enum('enabled' => 1, 'disabled' => 2)

      attribute :sku,               Type::String
      attribute :name,              Type::String
      attribute :description,       Type::String
      attribute :brand,             Type::String
      attribute :price,             Type::Coercible::Float
      attribute :special_price,     Type::Float.optional.default(nil)
      attribute :attribute_set_id,  Type::Integer
      attribute :status,            Statuses
      attribute :visibility,        Visibilities
      attribute :type_id,           ProductTypes
      attribute :weight,            Type::Coercible::Float
      attribute :quantity,          Type::Coercible::Float
      attribute :featured,          Type::String.default('0'.freeze).enum('0', '1')
      attribute :is_qty_decimal,    Type::Bool.default(false)
      attribute :category_ids,      Type::Array.of(Type::Integer).default([].freeze)
      attribute :images,            Type::Array.of(Type::Instance(CreateImage)).default([].freeze)
      attribute :website_ids,       Type::Array.of(Type::Integer).default([0].freeze)
      attribute :custom_attributes, Type::Array.default([], shared: true) do
        attribute :attribute_code,  Type::String
        attribute :value,           Type::Coercible::String
      end

      alias orig_custom_attributes custom_attributes

      def to_h
        {
          sku: sku,
          name: name.titlecase,
          price: price,
          status: Statuses.mapping[status],
          visibility: Visibilities.mapping[visibility],
          type_id: type_id,
          weight: weight,
          attribute_set_id: attribute_set_id,
          extension_attributes: {
            website_ids: website_ids,
            category_links: categories,
            stock_item: stock
          },
          media_gallery_entries: images.map(&:to_h),
          custom_attributes: custom_attributes.map(&:to_h)
        }
      end

      def stock
        {
          qty: quantity,
          is_in_stock: quantity.to_i > 0,
          is_qty_decimal: is_qty_decimal,
          show_default_notification_message: false,
          use_config_min_qty: true,
          min_qty: 1,
          use_config_min_sale_qty: 0,
          min_sale_qty: 0,
          use_config_max_sale_qty: true,
          max_sale_qty: 0,
          use_config_backorders: true,
          backorders: 0,
          use_config_notify_stock_qty: true,
          notify_stock_qty: 0,
          use_config_qty_increments: true,
          qty_increments: 0,
          use_config_enable_qty_inc: true,
          enable_qty_increments: true,
          use_config_manage_stock: true,
          manage_stock: true,
          low_stock_date: 'string',
          is_decimal_divided: is_qty_decimal,
          stock_status_changed_auto: 0
        }
      end

      def custom_attributes
        default_attributes = [
          CustomAttribute.new(attribute_code: 'description', value: description),
          CustomAttribute.new(attribute_code: 'url_key', value: name.parameterize ),
          CustomAttribute.new(attribute_code: 'product_brand', value: brand ),
          CustomAttribute.new(attribute_code: 'featured', value: featured)
        ]

        if special_price.to_f > 0
          default_attributes << CustomAttribute.new(attribute_code: 'special_price', value: special_price.to_s)
        end

        default_attributes + orig_custom_attributes
      end

      def categories
        category_ids.map { |c| { "category_id": c, "position": 0 } }
      end
    end
  end
end
