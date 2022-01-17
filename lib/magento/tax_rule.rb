# frozen_string_literal: true

module Magento
  class TaxRule < Model
    self.primary_key = :id
    self.endpoint = 'taxRules'

    class << self
      protected

      def query
        Query.new(self, api_resource: 'taxRules/search')
      end
    end
  end
end
