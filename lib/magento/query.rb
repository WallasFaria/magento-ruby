# frozen_string_literal: true

require 'cgi'

module Magento
  class Query
    ACCEPTED_CONDITIONS = [
      'eq',      # Equals.
      'finset',  # A value within a set of values
      'from',    # The beginning of a range. Must be used with to
      'gt',      # Greater than
      'gteq',    # Greater than or equal
      'in',      # In. The value can contain a comma-separated list of values.
      'like',    # Like. The value can contain the SQL wildcard characters when like is specified.
      'lt',      # Less than
      'lteq',    # Less than or equal
      'moreq',   # More or equal
      'neq',     # Not equal
      'nfinset', # A value that is not within a set of values
      'nin',     # Not in. The value can contain a comma-separated list of values.
      'notnull', # Not null
      'null',    # Null
      'to'       # The end of a range. Must be used with from
    ].freeze

    def initialize(model, request: Request.new)
      @model = model
      @request = request
      @filter_groups = nil
      @current_page = 1
      @page_size = 50
      @sort_orders = nil
      @fields = nil
    end

    def where(attributes)
      self.filter_groups = [] unless filter_groups
      filters = []
      attributes.each do |key, value|
        field, condition = parse_filter(key)
        value = parse_value_filter(condition, value)
        filters << { field: field, conditionType: condition, value: value }
      end
      filter_groups << { filters: filters }
      self
    end

    def page(current_page)
      self.current_page = current_page
      self
    end

    def page_size(page_size)
      @page_size = page_size
      self
    end

    alias_method :per, :page_size

    def select(*fields)
      fields = fields.map { |field| parse_field(field) }

      if model == Magento::Category
        self.fields = "children_data[#{fields.join(',')}]"
      else
        self.fields = "items[#{fields.join(',')}],search_criteria,total_count"
      end

      self
    end

    def order(attributes)
      if attributes.is_a?(String)
        self.sort_orders = [{ field: verify_id(attributes), direction: :asc }]
      elsif attributes.is_a?(Hash)
        self.sort_orders = []
        attributes.each do |field, direction|
          raise "Invalid sort order direction '#{direction}'" unless %w[asc desc].include?(direction.to_s)

          sort_orders << { field: verify_id(field), direction: direction }
        end
      end
      self
    end

    def all
      result = request.get("#{endpoint}?#{query_params}").parse
      field  = model == Magento::Category ? 'children_data' : 'items'
      RecordCollection.from_magento_response(result, model: model, iterable_field: field)
    end

    private

    attr_accessor :current_page, :filter_groups, :request, :sort_orders, :model, :fields

    def endpoint
      model.api_resource
    end

    def verify_id(field)
      return model.primary_key if (field.to_s == 'id') && (field.to_s != model.primary_key.to_s)

      field
    end

    def query_params
      query = {
        searchCriteria: {
          filterGroups: filter_groups,
          currentPage: current_page,
          sortOrders: sort_orders,
          pageSize: @page_size
        }.compact,
        fields: fields
      }.compact

      encode query
    end

    def parse_filter(key)
      patter = /(.*)_([a-z]+)$/
      raise 'Invalid format' unless key.match(patter)
      raise 'Condition not accepted' unless ACCEPTED_CONDITIONS.include?(key.match(patter)[2])

      key.match(patter).to_a[1..2]
    end

    def parse_value_filter(condition, value)
      if ['in', 'nin'].include?(condition) && value.is_a?(Array)
        value = value.join(',')
      end

      value
    end

    def parse_field(value)
      return verify_id(value) unless value.is_a? Hash

      value.map do |k, v|
        fields = v.is_a?(Array) ? v.map { |field| parse_field(field) } : [parse_field(v)]
        "#{k}[#{fields.join(',')}]"
      end.join(',')
    end

    def encode(value, key = nil)
      case value
      when Hash  then value.map { |k, v| encode(v, append_key(key, k)) }.join('&')
      when Array then value.each_with_index.map { |v, i| encode(v, "#{key}[#{i}]") }.join('&')
      when nil   then ''
      else
        "#{key}=#{CGI.escape(value.to_s)}"
      end
    end

    def append_key(root_key, key)
      root_key.nil? ? key : "#{root_key}[#{key}]"
    end
  end
end
