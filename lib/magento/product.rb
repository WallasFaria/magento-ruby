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

    def add_media(attributes)
      self.class.add_media(sku, attributes)
    end

    # returns true if the media was deleted
    def remove_media(media_id)
      self.class.remove_media(sku, media_id)
    end

    class << self
      alias_method :find_by_sku, :find

      def add_media(sku, attributes)
        request.post("products/#{sku}/media", { entry: attributes }).parse
      end

      # returns true if the media was deleted
      def remove_media(sku, media_id)
        request.delete("products/#{sku}/media/#{media_id}").parse
      end
    end
  end
end
