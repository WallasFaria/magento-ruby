# frozen_string_literal: true

module Magento
  class GuestCart < Model
    self.endpoint = 'guest-carts'
    self.primary_key = :cart_id

    def add_item(item_attributes)
      attributes = { cartItem: item_attributes.merge(quote_id: cart_id) }
      item = self.class.add_item(cart_id, attributes)
      @items = @items.reject {|i| i.item_id == item.item_id} << item if @items
      item
    end

    def delete_item(item_id, load_cart_info: false)
      self.class.delete_item(cart_id, item_id, load_cart_info: load_cart_info)
    end

    def delete_items(load_cart_info: false)
      self.class.delete_items(cart_id, load_cart_info: load_cart_info)
    end

    def get_items
      self.class.get_items(cart_id)
    end

    #
    # Set payment information to finish the order
    #
    # Example:
    # cart = Magento::GuestCart.find('gXsepZcgJbY8RCJXgGioKOO9iBCR20r7')
    #
    # # or use "build" to not request information from the magento API
    # cart = Magento::GuestCart.build({ 'cart_id' => 'aj8oUtY1Qi44Fror6UWVN7ftX1idbBKN' })
    #
    # cart.payment_information(
    #   email: 'customer@gmail.com',
    #   payment: { method: 'cashondelivery' }
    # )
    #
    # @return String: return the order id
    def payment_information(email:, payment:)
      attributes = { cartId: cart_id, paymentMethod: payment, email: email }
      self.class.payment_information(attributes)
    end

    #
    # Add a coupon by code to the current cart.
    #
    # Example
    # cart = Magento::GuestCart.find('gXsepZcgJbY8RCJXgGioKOO9iBCR20r7')
    # cart.add_coupon('COAU4HXE0I')
    #
    # @return Boolean: true on success, false otherwise
    def add_coupon(coupon)
      self.class.add_coupon(cart_id, coupon)
    end

    # Delete cart's coupon
    #
    # Example:
    # cart = Magento::GuestCart.find('gXsepZcgJbY8RCJXgGioKOO9iBCR20r7')
    # cart.delete_coupon()
    #
    # @return Boolean: true on success, raise exception otherwise
    def delete_coupon
      self.class.delete_coupon(cart_id)
    end

    class << self
      def create(load_cart_info: false)
        cart = build(cart_id: request.post(api_resource).parse)
        find cart.id if load_cart_info
      end

      def find(id)
        build request.get("#{api_resource}/#{id}").parse.merge(cart_id: id)
      end

      #
      # Set payment information to finish the order using class method
      #
      # Example:
      # Magento::GuestCart.payment_information(
      #   cartId: 'aj8oUtY1Qi44Fror6UWVN7ftX1idbBKN',
      #   paymentMethod: { method: 'cashondelivery' },
      #   email: email
      # )
      #
      # @return String: return the order id
      def payment_information(attributes)
        attributes.transform_keys(&:to_sym)
        url = "#{api_resource}/#{attributes[:cartId]}/payment-information"
        request.post(url, attributes).parse
      end

      def add_item(id, attributes)
        url  = "#{api_resource}/#{id}/items"
        hash = request.post(url, attributes).parse
        Magento::ModelMapper.map_hash(Magento::Item, hash)
      end

      def delete_item(id, item_id, load_cart_info: false)
        url = "#{api_resource}/#{id}/items/#{item_id}"
        request.delete(url).parse

        find(id) if load_cart_info
      end

      def delete_items(id, load_cart_info: false)
        items = get_items(id)

        items.each do |item|
          delete_item(id, item.item_id)
        end

        find(id) if load_cart_info
      end

      def get_items(id)
        url = "#{api_resource}/#{id}/items"
        hash = request.get(url).parse
        Magento::ModelMapper.map_array('Item', hash)
      end

      #
      # Add a coupon by code to a specified cart.
      #
      # Example
      # Magento::GuestCart.add_coupon(
      #   'aj8oUtY1Qi44Fror6UWVN7ftX1idbBKN',
      #   'COAU4HXE0I'
      # )
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
      # Magento::GuestCart.delete_coupon('aj8oUtY1Qi44Fror6UWVN7ftX1idbBKN')
      #
      # @return Boolean: true on success, raise exception otherwise
      def delete_coupon(id)
        url = "#{api_resource}/#{id}/coupons"
        request.delete(url).parse
      end
    end
  end
end
