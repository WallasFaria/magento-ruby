# frozen_string_literal: true

module Magento
  class Cart < Model
    self.endpoint = 'carts'
    self.primary_key = :id

    #
    # Add a item to the current cart.
    #
    # Example:
    #
    #   cart = Magento::Cart.find(1)
    #   cart.add_item({
    #     sku: '123456',
    #     qty: 1
    #   })
    #
    # @return Magento::Item: Added item
    def add_item(item_attributes)
      attributes = { cartItem: item_attributes.merge(quote_id: id) }
      item = self.class.add_item(id, attributes)
      @items = @items.reject { |i| i.item_id == item.item_id} << item if @items
      item
    end

    def delete_item(item_id)
      self.class.delete_item(id, item_id)
    end

    def delete_items
      self.class.delete_items(id)
    end

    def get_items
      self.class.get_items(id)
    end

    def update_item(item_id, item_attributes)
      attributes = { cartItem: item_attributes.merge(quote_id: id) }
      item = self.class.update_item(id, item_id, attributes)
      @items = @items.reject { |i| i.item_id == item.item_id} << item if @items
      item
    end

    #
    # Add a coupon by code to the current cart.
    #
    # Example:
    #
    #   cart = Magento::Cart.find(1)
    #   cart.add_coupon('COAU4HXE0I')
    #
    # @return Boolean: true on success, false otherwise
    def add_coupon(coupon)
      self.class.add_coupon(id, coupon)
    end

    #
    # Delete cart's coupon
    #
    # Example:
    #
    #   cart = Magento::Cart.find(1)
    #   cart.delete_coupon()
    #
    # @return Boolean: true on success, raise exception otherwise
    def delete_coupon
      self.class.delete_coupon(id)
    end

    def shipping_information(shipping_address:, billing_address:)
      self.class.shipping_information(id, shipping_address: shipping_address, billing_address: billing_address)
    end

    #
    # Place order for cart
    #
    # Example:
    #
    #   cart = Magento::Cart.find('12345')
    #
    #   # or use "build" to not request information from the magento API
    #   cart = Magento::GuestCart.build({ 'cart_id' => '12345' })
    #
    #   cart.order(
    #     email: 'customer@gmail.com',
    #     payment: { method: 'cashondelivery' }
    #   )
    #
    # @return String: return the order id
    def order(email:, payment:)
      attributes = { cartId: id, paymentMethod: payment, email: email }
      self.class.order(attributes)
    end

    class << self
      #
      # Example:
      #
      #   Magento::Cart.create({customer_id: 1})
      #
      # @return Magento::Cart: Cart object for customer
      def create(attributes)
        id = request.post("#{api_resource}/mine", attributes).parse
        find id
      end

      def add_item(id, attributes)
        url  = "#{api_resource}/#{id}/items"
        hash = request.post(url, attributes).parse
        Magento::ModelMapper.map_hash(Magento::Item, hash)
      end

      def delete_item(id, item_id)
        url = "#{api_resource}/#{id}/items/#{item_id}"
        request.delete(url).parse
      end

      def delete_items(id)
        items = get_items(id)

        items.each do |item|
          delete_item(id, item.item_id)
        end
      end

      def get_items(id)
        url = "#{api_resource}/#{id}/items"
        hash = request.get(url).parse
        Magento::ModelMapper.map_array('Item', hash)
      end

      def update_item(id, item_id, attributes)
        url = "#{api_resource}/#{id}/items/#{item_id}"
        hash = request.put(url, attributes).parse
        Magento::ModelMapper.map_hash(Magento::Item, hash)
      end

      #
      # Add a coupon by code to a specified cart.
      #
      # Example:
      #
      #   Magento::Cart.add_coupon(
      #     1,
      #     'COAU4HXE0I'
      #   )
      #
      # @return Boolean: true on success, false otherwise
      def add_coupon(id, coupon)
        url = "#{api_resource}/#{id}/coupons/#{coupon}"
        request.put(url, nil).parse
      end

      #
      # Delete a coupon from a specified cart.
      #
      # Example:
      #
      #   Magento::Cart.delete_coupon(1)
      #
      # @return Boolean: true on success, raise exception otherwise
      def delete_coupon(id)
        url = "#{api_resource}/#{id}/coupons"
        request.delete(url).parse
      end

      def shipping_information(id, shipping_address:, billing_address:)
        url = "#{api_resource}/#{id}/shipping-information"
        attributes = {
          addressInformation: {
            shipping_address: shipping_address,
            billing_address: billing_address
          }
        }
        request.post(url, attributes).parse
      end

      #
      # Place order for cart
      #
      # Example:
      #
      #   Magento::Cart.order(
      #     cartId: '12345',
      #     paymentMethod: { method: 'cashondelivery' },
      #     email: email
      #   )
      #
      # @return String: return the order id
      def order(attributes)
        attributes = attributes.transform_keys(&:to_sym)
        url = "#{api_resource}/#{attributes[:cartId]}/order"
        request.put(url, attributes).parse
      end
    end
  end
end
