module Magento
  class Product < Model
    class << self
      def find_by_sky(sku)
        product_hash = Request.get("products/#{sku}").parse
        mapHash Product, product_hash
      end
    end
  end
end