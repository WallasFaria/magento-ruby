module Magento
  class Inventory
    class << self
      # 
      # ==== Example
      #
      #   Inventory.is_product_salable_for_requested_qty(
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

      # 
      # ==== Example
      #
      #   Inventory.update_source_items(
      #     [
      #       {
      #         "sku": "new_product1",
      #         "source_code": "central",
      #         "quantity": 1000,
      #         "status": 1
      #       },
      #       {
      #         "sku": "new_product1",
      #         "source_code": "east",
      #         "quantity": 2000,
      #         "status": 1
      #       }
      #     ]
      #   )
      #   # => []
      #
      # @return Array
      def update_source_items(source_items)
        body = { sourceItems: source_items }
        Request.new.post('inventory/source-items', body).parse
      end
    end
  end
end
