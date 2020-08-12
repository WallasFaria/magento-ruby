# frozen_string_literal: true

module Magento
  class Order < Model
    self.primary_key = :entity_id
    self.entity_key = :entity

    def save
      raise NotImplementedError
    end

    def update(attrs)
      raise "'entity_id' not found" if @entity_id.nil?

      attrs[:entity_id] = @entity_id
      self.class.update(attrs)
    end

    class << self
      def update(attributes)
        hash = request.put('orders/create', { entity_key => attributes }).parse
        build(hash)
      end
    end
  end
end
