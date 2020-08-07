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

    class << self
      def create(load_cart_info: false)
        cart = build(cart_id: request.post(api_resource).parse)
        find cart.id if load_cart_info
      end

      def find(id)
        cart = build request.get("#{api_resource}/#{id}").parse.merge(cart_id: id)
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
    end
  end
end
