# frozen_string_literal: true

module Magento
  class TaxRate < Model
    self.primary_key = :id
    self.endpoint = 'taxRates'

    class << self
      protected

      def query
        Query.new(self, api_resource: 'taxRates/search')
      end
    end
  end
end
