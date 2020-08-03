module Magento
  class Product < Model
    class << self
      alias_method :find_by_sku, :find
    end
  end
end
