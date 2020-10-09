module Magento
  class Product < Model
    self.primary_key = :sku

    def method_missing(m, *params, &block)
      attr(m) || super(m, *params, &block)
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
    # product = Magento::Product.find(1)
    # product.add_group_price(2, 3, 3.99)
    # 
    # OR
    # 
    # Magento::Product.add_group_price(1, 2, 3, 3.99)
    # 
    # @return {Boolean}
    def add_group_price(customer_group_id, qty, price)
      self.class.add_group_price(sku, customer_group_id, qty, price)
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
      # Param {qty} is the minimun amount to apply the price
      # 
      # @return {Boolean}
      def add_group_price(sku, customer_group_id, qty, price)
        request.post(
          "products/#{sku}/group-prices/#{customer_group_id}/tiers/#{qty}/price/#{price}"
        ).parse
      end
    end
  end
end
