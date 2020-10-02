# frozen_string_literal: true

module Magento
  module Params
    class CreateCategoria
      attr_accessor :name, :parent_id, :path, :is_active

      def initialize(name:, is_active: true, parent_id: nil, path: nil)
        self.name = name
        self.is_active = is_active
        self.parent_id = parent_id
        self.path = path
      end

      def to_h
        {
          "name": name,
          "parent_id": parent_id,
          "is_active": is_active,
          "path": path
        }
      end
    end
  end
end
