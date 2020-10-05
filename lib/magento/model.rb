# frozen_string_literal: true

require 'forwardable'

module Magento
  class Model
    include Magento::ModelParser

    def save
      self.class.update(send(self.class.primary_key), to_h) do |hash|
        update_attributes(hash)
      end
    end
    
    def update(attrs)
      raise "#{self.class.name} not saved" if send(self.class.primary_key).nil?

      self.class.update(send(self.class.primary_key), attrs) do |hash|
        update_attributes(hash)
      end
    end

    def delete
      self.class.delete(send(self.class.primary_key))
    end

    def id
      @id || send(self.class.primary_key)
    end

    protected def update_attributes(hash)
      ModelMapper.map_hash(self, hash)
    end

    class << self
      extend Forwardable

      def_delegators :query, :all, :find_each, :page, :per, :page_size, :order, :select, 
                     :where, :first, :find_by, :count

      def find(id)
        hash = request.get("#{api_resource}/#{id}").parse
        build(hash)
      end

      def create(attributes)
        body = { entity_key => attributes }
        hash = request.post(api_resource, body).parse
        build(hash)
      end

      def delete(id)
        request.delete("#{api_resource}/#{id}").status.success?
      end

      def update(id, attributes)
        body = { entity_key => attributes }
        hash = request.put("#{api_resource}/#{id}", body).parse

        block_given? ? yield(hash) : build(hash)
      end

      def api_resource
        endpoint || Magento.inflector.pluralize(entity_name)
      end

      def entity_name
        Magento.inflector.underscore(name).sub('magento/', '')
      end

      def primary_key
        @primary_key || :id
      end

      protected

      attr_writer :primary_key
      attr_accessor :endpoint, :entity_key

      def entity_key
        @entity_key || entity_name
      end

      def query
        Query.new(self)
      end

      def request
        Request.new
      end
    end
  end
end
