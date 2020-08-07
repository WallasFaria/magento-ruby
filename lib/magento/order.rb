module Magento
  class Order < Model
    self.primary_key = :entity_id
    self.entity_key = :entity
  end
end