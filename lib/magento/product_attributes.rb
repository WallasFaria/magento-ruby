# frozen_string_literal: true

module Magento
  class ProductsAttributes < Model
    self.primary_key = :id
    self.endpoint = 'products/attributes'

    class << self
      protected

      def query
        Query.new(self, api_resource: 'products/attributes')
      end
    end
  end
end
