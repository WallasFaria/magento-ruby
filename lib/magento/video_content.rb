# frozen_string_literal: true

module Magento
  class VideoContent < Model
    self.primary_key = :id
    self.endpoint = 'videoContent'

    class << self
      protected

      def query
        Query.new(self, api_resource: 'videoContent/search')
      end
    end
  end
end
