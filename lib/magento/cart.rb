# frozen_string_literal: true

module Magento
  class Cart < Model
    self.endpoint = 'carts'
    self.primary_key = :id

    #
    # Add a coupon by code to the current cart.
    #
    # Example
    # cart = Magento::Cart.find(1)
    # cart.add_coupon('COAU4HXE0I')
    #
    # @return Boolean: true on success, false otherwise
    def add_coupon(coupon)
      self.class.add_coupon(id, coupon)
    end

    #
    # Delete cart's coupon
    #
    # Example:
    # cart = Magento::Cart.find(1)
    # cart.delete_coupon()
    #
    # @return Boolean: true on success, raise exception otherwise
    def delete_coupon
      self.class.delete_coupon(id)
    end

    class << self
      #
      # Add a coupon by code to a specified cart.
      #
      # Example
      # Magento::Cart.add_coupon(
      #   1,
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
      # Magento::Cart.delete_coupon(1)
      #
      # @return Boolean: true on success, raise exception otherwise
      def delete_coupon(id)
        url = "#{api_resource}/#{id}/coupons"
        request.delete(url).parse
      end
    end
  end
end
