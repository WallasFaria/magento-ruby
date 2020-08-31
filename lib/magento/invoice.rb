# frozen_string_literal: true

module Magento
  class Invoice < Model
    self.primary_key = :entity_id
    self.entity_key = :entity

    #
    # Sets invoice capture.
    def capture
      self.class.capture(id)
    end

    #
    # Voids a specified invoice.
    #
    # @return {Boolean}
    def void
      self.class.void(id)
    end

    #
    # Emails a user a specified invoice.
    #
    # @return {Boolean}
    def send_email
      self.class.send_email(id)
    end

    #
    # Create refund for invoice
    #
    # invoice = Magento::Invoice.find(invoice_id)
    #
    # invoice.refund # or you can pass parameters
    # invoice.invoice(notify: false) # See the refund class method for more information
    #
    # @return {Integer} return the refund id
    def refund(refund_params = nil)
      self.class.refund(id, refund_params)
    end

    class << self
      def save
        raise NotImplementedError
      end

      def update(_attributes)
        raise NotImplementedError
      end

      def create(_attributes)
        raise NotImplementedError
      end

      #
      # Sets invoice capture.
      def capture(invoice_id)
        request.post("invoices/#{invoice_id}/capture").parse
      end

      #
      # Voids a specified invoice.
      #
      # @return {Boolean}
      def void(invoice_id)
        request.post("invoices/#{invoice_id}/avoid").parse
      end

      #
      # Emails a user a specified invoice.
      #
      # @return {Boolean}
      def send_email(invoice_id)
        request.post("invoices/#{invoice_id}/emails").parse
      end

      #
      # Lists comments for a specified invoice.
      #
      # Magento::Invoice.comments(invoice_id).all
      # Magento::Invoice.comments(invoice_id).where(created_at_gt: Date.today.prev_day).all
      def comments(invoice_id)
        api_resource = "invoices/#{invoice_id}/comments"
        Query.new(PolymorphicModel.new(Comment, api_resource))
      end

      #
      # Create refund for invoice
      #
      # Magento::Invoice.refund(invoice_id)
      #
      # or
      #
      # Magento::Invoice.refund(
      #   invoice_id,
      #   items: [
      #     {
      #       extension_attributes: {},
      #       order_item_id: 0,
      #       qty: 0
      #     }
      #   ],
      #   isOnline: true,
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
      # to complete [documentation](https://magento.redoc.ly/2.4-admin/tag/invoicescomments#operation/salesRefundInvoiceV1ExecutePost)
      #
      # @return {Integer} return the refund id
      def refund(invoice_id, refund_params=nil)
        request.post("invoice/#{invoice_id}/refund", refund_params).parse
      end
    end
  end
end
