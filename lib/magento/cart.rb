# frozen_string_literal: true

module Magento
  class Cart < Model
    self.endpoint = 'carts'
    self.primary_key = :id

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
        attributes.transform_keys(&:to_sym)
        url = "#{api_resource}/#{attributes[:cartId]}/order"
        request.put(url, attributes).parse
      end
    end
  end
end
