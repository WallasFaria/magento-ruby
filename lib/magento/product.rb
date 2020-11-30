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

    def respond_to?(attribute_code)
      super || @custom_attributes&.any? { |a| a.attribute_code == attribute_code.to_s }
    end

    def add_media(attributes)
      self.class.add_media(sku, attributes)
    end

    # returns true if the media was deleted
    def remove_media(media_id)
      self.class.remove_media(sku, media_id)
    end

    # 
    # Add {price} on product {sku} for specified {customer_group_id}
    # 
    # Param {quantity} is the minimun amount to apply the price
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

    class << self
      alias_method :find_by_sku, :find

      def add_media(sku, attributes)
        request.post("products/#{sku}/media", { entry: attributes }).parse
      end

      # returns true if the media was deleted
      def remove_media(sku, media_id)
        request.delete("products/#{sku}/media/#{media_id}").parse
      end

      # Add {price} on product {sku} for specified {customer_group_id}
      # 
      # Param {quantity} is the minimun amount to apply the price
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
    end
  end
end
