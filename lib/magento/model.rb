# frozen_string_literal: true

require 'forwardable'

module Magento
  class Model
    include Magento::ModelParser

    def save
      self.class.update(send(self.class.primary_key), to_h)
    end

    def update(attrs)
      raise "#{self.class.name} not saved" if send(self.class.primary_key).nil?

      attrs.each { |key, value| send("#{key}=", value) }
      save
    end

    def delete
      self.class.delete(send(self.class.primary_key))
    end

    def id
      @id || send(self.class.primary_key)
    end

    class << self
      extend Forwardable

      def_delegators :query, :all, :page, :per, :page_size, :order, :select, :where

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
        build(hash)
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
        @request ||= Request.new
      end
    end
  end
end
