module Magento
  class Product < Model
    self.primary_key = :sku

    class << self
      alias_method :find_by_sku, :find
    end
  end
end
