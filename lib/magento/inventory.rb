module Magento
  class Inventoty
    class << self
      # 
      # ==== Example
      #
      #   Inventoty.is_product_salable_for_requested_qty(
      #     sku: '4321',
      #     stock_id: 1,
      #     requested_qty: 2
      #   )
      #   # =>
      #   OpenStruct {
      #     :salable => false,
      #     :errors => [
      #       [0] {
      #         "code" => "back_order-disabled",
      #         "message" => "Backorders are disabled"
      #       },
      #       ...
      #     ]
      #   }
      #
      # @return OpenStruct
      def is_product_salable_for_requested_qty(sku:, stock_id:, requested_qty:)
        result = Request.new.get(
          "inventory/is-product-salable-for-requested-qty/#{sku}/#{stock_id}/#{requested_qty}"
        ).parse

        OpenStruct.new(result)
      end

      def get_product_salable_quantity(sku:, stock_id:)
        Request.new.get(
          "inventory/get-product-salable-quantity/#{sku}/#{stock_id}"
        ).parse
      end
    end
  end
end
