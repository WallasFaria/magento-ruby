# frozen_string_literal: true

module Magento
  class Order < Model
    self.primary_key = :entity_id
    self.entity_key = :entity

    def save
      raise NotImplementedError
    end

    def update(attrs)
      raise "'entity_id' not found" if @entity_id.nil?

      self.class.update(@entity_id, attrs)
    end

    def cancel
      self.class.cancel(id)
    end

    #
    # Invoice current order
    #
    # order = Magento::Order.find(order_id)
    #
    # order.invoice # or you can pass parameters
    # order.invoice(capture: false) # See the invoice class method for more information
    #
    # @return String: return the invoice id
    def invoice(params=nil)
      self.class.invoice(id, params)
    end

    
    #
    # Create offline refund for order
    #
    # order = Magento::Order.find(order_id)
    #
    # order.refund # or you can pass parameters
    # order.invoice(notify: false) # See the refund class method for more information
    #
    # @return {Integer} return the refund id
    def refund(refund_params = nil)
      self.class.refund(id, refund_params)
    end

    #
    # Creates new Shipment for given Order.
    #
    # order = Magento::Order.find(order_id)
    #
    # order.ship # or you can pass parameters
    # order.ship(notify: false) # See the shipment class method for more information
    #
    # Return the shipment id
    def ship(params=nil)
      self.class.ship(id, params)
    end

    class << self
      def update(entity_id, attributes)
        attributes[:entity_id] = entity_id
        hash = request.put('orders/create', { entity_key => attributes }).parse
        build(hash)
      end

      # @return {Boolean}
      def cancel(order_id)
        request.post("orders/#{order_id}/cancel").parse
      end

      #
      # Invoice an order
      #
      # Magento::Order.invoice(order_id)
      #
      # or
      #
      # Magento::Order.invoice(
      #   order_id,
      #   capture: false,
      #   appendComment: true,
      #   items: [{ order_item_id: 123, qty: 1 }], # pass items to partial invoice
      #   comment: {
      #     extension_attributes: { },
      #     comment: "string",
      #     is_visible_on_front: 0
      #   },
      #   notify: true
      # )
      #
      # to complete [documentation](https://magento.redoc.ly/2.4-admin/tag/orderorderIdinvoice#operation/salesInvoiceOrderV1ExecutePost)
      #
      # @return String: return the invoice id
      def invoice(order_id, invoice_params=nil)
        request.post("order/#{order_id}/invoice", invoice_params).parse
      end

      
      #
      # Create offline refund for order
      #
      # Magento::Order.refund(order_id)
      #
      # or
      #
      # Magento::Order.refund(
      #   order_id,
      #   items: [
      #     {
      #       extension_attributes: {},
      #       order_item_id: 0,
      #       qty: 0
      #     }
      #   ],
      #   notify: true,
      #   appendComment: true,
      #   comment: {
      #     extension_attributes: {},
      #     comment: string,
      #     is_visible_on_front: 0
      #   },
      #   arguments: {
      #     shipping_amount: 0,
      #     adjustment_positive: 0,
      #     adjustment_negative: 0,
      #     extension_attributes: {
      #       return_to_stock_items: [
      #         0
      #       ]
      #     }
      #   }
      # )
      #
      # to complete [documentation](https://magento.redoc.ly/2.4-admin/tag/invoicescomments#operation/salesRefundOrderV1ExecutePost)
      #
      # @return {Integer} return the refund id
      def refund(order_id, refund_params = nil)
        request.post("order/#{order_id}/refund", refund_params).parse
      end

      #
      # Creates new Shipment for given Order.
      #
      # Magento::Order.ship(order_id)
      #
      # or
      #
      # Magento::Order.ship(
      #   order_id,
      #   capture: false,
      #   appendComment: true,
      #   items: [{ order_item_id: 123, qty: 1 }], # pass items to partial shipment
      #   tracks: [
      #     {
      #       extension_attributes: { },
      #       track_number: "string",
      #       title: "string",
      #       carrier_code: "string"
      #     }
      #   ]
      #   notify: true
      # )
      #
      # to complete [documentation](https://magento.redoc.ly/2.4-admin/tag/orderorderIdship#operation/salesShipOrderV1ExecutePost)
      #
      # @return {String}: return the shipment id
      def ship(order_id, shipment_params = nil)
        request.post("order/#{order_id}/ship", shipment_params).parse
      end
    end
  end
end
