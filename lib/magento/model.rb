# frozen_string_literal: true

require 'forwardable'

module Magento
  class Model
    def save
      body = ModelMapper.from_object(self).to_hash
      self.class.update(send(self.class.primary_key), body)
    end

    def update(attrs)
      raise "#{self.class.name} not saved" if send(self.class.primary_key).nil?

      attrs.each { |key, value| send("#{key}=", value) }
      save
    end

    def delete
      self.class.delete(send(self.class.primary_key))
    end

    class << self
      extend Forwardable
      
      def_delegators :query, :all, :page, :per, :page_size, :order, :select, :where

      def find(id)
        hash = request.get("#{api_resource}/#{id}").parse
        ModelMapper.from_hash(hash).to_model(self)
      end

      def create(attributes)
        body = { entity_name => attributes }
        hash = request.post(api_resource, body).parse
        ModelMapper.from_hash(hash).to_model(self)
      end

      def delete(id)
        request.delete("#{api_resource}/#{id}").status.success?
      end

      def update(id, attributes)
        body = { entity_name => attributes }
        hash = request.put("#{api_resource}/#{id}", body).parse
        ModelMapper.from_hash(hash).to_model(self)
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
      attr_accessor :endpoint

      def query
        Query.new(self)
      end

      def request
        @request ||= Request.new
      end
    end
  end
end
