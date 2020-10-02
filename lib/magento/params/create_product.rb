module Magento
  module Params
    class CreateProduct
      attr_accessor(
        :sku,
        :name,
        :description,
        :brand,
        :type_id,
        :price,
        :special_price,
        :attribute_set_id,
        :status,
        :visibility,
        :weight,
        :quantity,
        :is_qty_decimal,
        :category_ids,
        :images,
        :website_ids,
        :custom_attributes
      )

      ###
      # @param sku [String]
      # @param name [String]
      # @param price [Float]
      # @param quantity [Float]
      # @param brand [String]
      # @param attribute_set_id [Integer]
      # @param special_price: [Float]
      # @param description: [String]
      # @param status: [Integer] Default: 1, options: 1- Enabled, 2 - Disabled
      # @param visibility: [Integer] Default: 4, options: 1 - Not Visible Individually, 2 - Catalog, 3 - Search, 4 - Catalog, Search.
      # @param weight: [Float] Default: 0.3
      # @param is_qty_decimal: [Boolean] Default: false
      # @param images: [Array<Magento::Params::CreateImage>] Default: []
      # @param website_ids: [Array<Integer] Default: [0]
      # @param category_ids: [Array<String] Default: []
      # @param attributes: [Array<Magento::Params::CreateAttribute>] Default: []
      ###
      def initialize(sku:, name:, price:, quantity:, brand:, attribute_set_id:, **params)
        self.sku               = sku
        self.name              = name
        self.price             = price
        self.quantity          = quantity
        self.brand             = brand
        self.attribute_set_id  = attribute_set_id
        self.special_price     = params[:special_price]
        self.description       = params[:description] || ''
        self.type_id           = params[:type_id] || 'simple'
        self.status            = params[:status] || 1
        self.visibility        = params[:visibility] || 4
        self.weight            = params[:weight] || 0.3
        self.is_qty_decimal    = params[:is_qty_decimal] || false
        self.images            = params[:images] || []
        self.website_ids       = params[:website_ids] || [0]
        self.category_ids      = params[:category_ids] || []
        self.custom_attributes = params[:custom_attributes] || []
      end

      def add_custom_attribute(code, value)
        custom_attributes << CreateAttribute.new(code: code, value: value)
      end

      def to_h
        {
          sku: sku,
          name: name.titlecase,
          price: price,
          status: status,
          visibility: visibility,
          type_id: type_id,
          weight: weight,
          attribute_set_id: attribute_set_id,
          extension_attributes: {
            website_ids: website_ids,
            category_links: categories,
            stock_item: stock
          },
          media_gallery_entries: images.map(&:to_h),
          custom_attributes: attributes.map(&:to_h)
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

      def attributes
        list = [
          CreateCustomAttribute.new(code: 'description', value: description),
          CreateCustomAttribute.new(code: 'url_key', value: name.parameterize),
          CreateCustomAttribute.new(code: 'product_brand', value: brand),
        ]

        list << CreateCustomAttribute.new(code: 'special_price', value: special_price) if special_price.to_f > 0

        list + custom_attributes
      end

      def categories
        category_ids.map { |c| { "category_id": c, "position": 0 } }
      end
    end
  end
end
