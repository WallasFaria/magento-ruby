# frozen_string_literal: true

require 'forwardable'

module Magento
  class RecordCollection
    attr_accessor :items, :search_criteria, :total_count
    extend Forwardable

    def initialize
      @items = []
      @search_criteria = Magento::SearchCriterium
    end

    def_delegators :@search_criteria, :current_page, :filter_groups, :page_size

    def_delegators :@items, :last, :each_index, :sample, :sort, :count, :[],
                   :find_index, :select, :filter, :reject, :collect, :map,
                   :first, :all?, :any?, :none?, :one?, :reverse_each, :take,
                   :empty?, :reverse, :length, :size, :each, :find,
                   :take_while, :index, :sort_by

    alias_method :per, :page_size

    class << self
      def from_magento_response(response, model:)
        if model == Magento::Category
          handle_category_response(response, model)
        else
          handle_response(response, model)
        end
      end

      private

      def handle_category_response(response, model)
        collection = Magento::RecordCollection.new

        collection.items = response['children_data']&.map do |item|
          ModelMapper.from_hash(item).to_model(model)
        end || []

        collection.total_count = response['children_data']&.size || 0
        collection
      end

      def handle_response(response, model)
        collection = Magento::RecordCollection.new

        collection.items = response['items']&.map do |item|
          ModelMapper.from_hash(item).to_model(model)
        end || []

        collection.total_count = response['total_count'] if response['total_count']

        if response['search_criteria']
          collection.search_criteria = ModelMapper
            .from_hash(response['search_criteria'])
            .to_model(Magento::SearchCriterium)
        end

        collection
      end
    end
  end
end
