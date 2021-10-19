# frozen_string_literal: true

module Magento
  class TaxRate < Model
    self.primary_key = :id
    self.endpoint = 'taxRates'
  end
end
