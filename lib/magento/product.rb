module Magento
  class Product < Model
    self.primary_key = :sku

    def method_missing(m)
      attr(m) || super
    end

    # returns custom_attribute value by custom_attribute code
    # return nil if custom_attribute is not present
    def attr(attribute_code)
      @custom_attributes&.find { |a| a.attribute_code == attribute_code.to_s }&.value
    end

    def respond_to?(attribute_code)
      super || @custom_attributes&.any? { |a| a.attribute_code == attribute_code.to_s }
    end

    class << self
      alias_method :find_by_sku, :find
    end
  end
end
