module Magento
  class Product < Model
    class << self
      def find_by_sku(sku)
        product_hash = request.get("products/#{sku}").parse
        mapHash Product, product_hash
      end
    end
  end
end