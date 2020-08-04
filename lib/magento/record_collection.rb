# frozen_string_literal: true

require 'forwardable'

module Magento
  class RecordCollection
    attr_reader :items, :search_criteria, :total_count
    extend Forwardable

    def initialize(items:, total_count: nil, search_criteria: nil)
      @items           = items || []
      @total_count     = total_count || @items.size
      @search_criteria = search_criteria || Magento::SearchCriterium.new
    end

    def_delegators :@search_criteria, :current_page, :filter_groups, :page_size

    def_delegators :@items, :count, :length, :size, :first, :last, :[],
                   :find, :each, :each_with_index, :sample, :map, :select, 
                   :filter, :reject, :collect, :take, :take_while, :sort,
                   :sort_by, :reverse_each, :reverse, :all?, :any?, :none?, 
                   :one?, :empty?

    alias per page_size

    class << self
      def from_magento_response(response, model:, iterable_field: 'items')
        items = response[iterable_field]&.map do |item|
          ModelMapper.from_hash(item).to_model(model)
        end

        search_criteria = ModelMapper
                          .from_hash(response['search_criteria'])
                          .to_model(Magento::SearchCriterium)

        Magento::RecordCollection.new(
          items: items,
          total_count: response['total_count'],
          search_criteria: search_criteria
        )
      end
    end
  end
end
