module Magento
  class Product < Model
    self.primary_key = :sku

    def method_missing(m, *params, &block)
      attr(m) || super(m, *params, &block)
    end

    def stock
      extension_attributes&.stock_item
    end

    def stock_quantity
      stock&.qty
    end

    # returns custom_attribute value by custom_attribute code
    # return nil if custom_attribute is not present
    def attr(attribute_code)
      @custom_attributes&.find { |a| a.attribute_code == attribute_code.to_s }&.value
    end

    def set_custom_attribute(code, value)
      @custom_attributes ||= []
      attribute = @custom_attributes.find { |a| a.attribute_code == code.to_s }

      if attribute
        attribute.value = value
      else
        @custom_attributes << Magento::CustomAttribute.build(
          attribute_code: code.to_s,
          value: value
        )
      end
    end

    def respond_to?(attribute_code)
      super || @custom_attributes&.any? { |a| a.attribute_code == attribute_code.to_s }
    end

    # Create new gallery entry
    # 
    # Example:
    #
    #   product = Magento::Product.find('sku')
    #
    #   product.add_media(
    #     media_type: 'image',
    #     label: 'Image label',
    #     position: 1,
    #     content: {
    #       base64_encoded_data: 'image-string-base64',
    #       type: 'image/jpg',
    #       name: 'filename.jpg'
    #     },
    #     types: ['image']
    #   )
    #
    # Or you can use the Magento::Params::CreateImage helper class
    #
    #   params = Magento::Params::CreateImage.new(
    #     title: 'Image title',
    #     path: '/path/to/image.jpg', # or url
    #     position: 1,
    #   ).to_h
    #
    #   product.add_media(params)
    #
    def add_media(attributes)
      self.class.add_media(sku, attributes)
    end

    # returns true if the media was deleted
    def remove_media(media_id)
      self.class.remove_media(sku, media_id)
    end

    # Add {price} on product {sku} for specified {customer_group_id}
    # 
    # Param {quantity} is the minimum amount to apply the price
    # 
    # product = Magento::Product.find(1)
    # product.add_tier_price(3.99, quantity: 1, customer_group_id: :all)
    # 
    # OR
    # 
    # Magento::Product.add_tier_price(1, 3.99, quantity: 1, customer_group_id: :all)
    # 
    # @return {Boolean}
    def add_tier_price(price, quantity:, customer_group_id: :all)
      self.class.add_tier_price(
        sku, price, quantity: quantity, customer_group_id: customer_group_id
      )
    end

    #
    # Remove tier price
    #
    #   product = Magento::Product.find(1)
    #   product.remove_tier_price(quantity: 1, customer_group_id: :all)
    #
    # @return {Boolean}
    def remove_tier_price(quantity:, customer_group_id: :all)
      self.class.remove_tier_price(
        sku, quantity: quantity, customer_group_id: customer_group_id
      )
    end

    # Update product stock
    #
    #   product = Magento::Product.find('sku')
    #   product.update_stock(qty: 12, is_in_stock: true)
    #
    # see all available attributes in: https://magento.redoc.ly/2.4.1-admin/tag/productsproductSkustockItemsitemId
    def update_stock(attributes)
      self.class.update_stock(sku, id, attributes)
    end

    # Assign a product link to another product
    #
    #   product = Magento::Product.find('sku')
    #
    #   product.create_links([
    #     {
    #       link_type: 'upsell',
    #       linked_product_sku: 'linked_product_sku',
    #       linked_product_type: 'simple',
    #       position: position,
    #       sku: 'product-sku'
    #     }
    #   ])
    #
    def create_links(product_links)
      self.class.create_links(sku, product_links)
    end

    def remove_link(link_type:, linked_product_sku:)
      self.class.remove_link(sku, link_type: link_type, linked_product_sku: linked_product_sku)
    end

    class << self
      alias_method :find_by_sku, :find

      # Create new gallery entry
      #
      # Example:
      #
      #   Magento::Product.add_media('sku', {
      #     media_type: 'image',
      #     label: 'Image title',
      #     position: 1,
      #     content: {
      #       base64_encoded_data: 'image-string-base64',
      #       type: 'image/jpg',
      #       name: 'filename.jpg'
      #     },
      #     types: ['image']
      #   })
      #
      # Or you can use the Magento::Params::CreateImage helper class
      #
      #   params = Magento::Params::CreateImage.new(
      #     title: 'Image title',
      #     path: '/path/to/image.jpg', # or url
      #     position: 1,
      #   ).to_h
      #
      #   Magento::Product.add_media('sku', params)
      #
      def add_media(sku, attributes)
        request.post("products/#{sku}/media", { entry: attributes }).parse
      end

      # returns true if the media was deleted
      def remove_media(sku, media_id)
        request.delete("products/#{sku}/media/#{media_id}").parse
      end

      # Add {price} on product {sku} for specified {customer_group_id}
      # 
      # Param {quantity} is the minimum amount to apply the price
      # 
      # @return {Boolean}
      def add_tier_price(sku, price, quantity:, customer_group_id: :all)
        request.post(
          "products/#{sku}/group-prices/#{customer_group_id}/tiers/#{quantity}/price/#{price}"
        ).parse
      end

      # Remove tier price
      #
      #   Product.remove_tier_price('sku', quantity: 1, customer_group_id: :all)
      # 
      # @return {Boolean}
      def remove_tier_price(sku, quantity:, customer_group_id: :all)
        request.delete(
          "products/#{sku}/group-prices/#{customer_group_id}/tiers/#{quantity}"
        ).parse
      end

      # Update product stock
      #
      #   Magento::Product.update_stock(sku, id, {
      #     qty: 12,
      #     is_in_stock: true 
      #   })
      #
      # see all available attributes in: https://magento.redoc.ly/2.4.1-admin/tag/productsproductSkustockItemsitemId
      def update_stock(sku, id, attributes)
        request.put("products/#{sku}/stockItems/#{id}", stockItem: attributes).parse
      end

      # Assign a product link to another product
      #
      #   Product.create_links('product-sku', [
      #     {
      #       link_type: 'upsell',
      #       linked_product_sku: 'linked_product_sku',
      #       linked_product_type: 'simple',
      #       position: position,
      #       sku: 'product-sku'
      #     }
      #   ])
      #
      def create_links(sku, product_links)
        request.post("products/#{sku}/links", { items: product_links })
      end

      def remove_link(sku, link_type:, linked_product_sku:)
        request.delete("products/#{sku}/links/#{link_type}/#{linked_product_sku}")
      end
    end
  end
end
