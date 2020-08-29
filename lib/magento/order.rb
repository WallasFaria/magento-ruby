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

      attrs[:entity_id] = @entity_id
      self.class.update(attrs)
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
    def invoice(invoice_attributes=nil)
      self.class.invoice(id, invoice_attributes)
    end

    class << self
      def update(attributes)
        hash = request.put('orders/create', { entity_key => attributes }).parse
        build(hash)
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
      def invoice(order_id, invoice_attributes=nil)
        request.post("order/#{order_id}/invoice", invoice_attributes).parse
      end
    end
  end
end
