# frozen_string_literal: true

require 'time'
require 'dry/inflector'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/module/delegation'

require_relative 'magento/configuration'
require_relative 'magento/errors'
require_relative 'magento/request'
require_relative 'magento/model_mapper'
require_relative 'magento/params'
require_relative 'magento/polymorphic_model'
require_relative 'magento/model'
require_relative 'magento/record_collection'
require_relative 'magento/query'
require_relative 'magento/category'
require_relative 'magento/product'
require_relative 'magento/country'
require_relative 'magento/customer'
require_relative 'magento/order'
require_relative 'magento/invoice'
require_relative 'magento/guest_cart'
require_relative 'magento/sales_rule'
require_relative 'magento/inventory'
require_relative 'magento/import'
require_relative 'magento/cart'
require_relative 'magento/tax_rule'
require_relative 'magento/tax_rate'

require_relative 'magento/params/create_custom_attribute'
require_relative 'magento/params/create_image'
require_relative 'magento/params/create_category'
require_relative 'magento/params/create_product'
require_relative 'magento/params/create_product_link'

Dir[File.expand_path('magento/shared/*.rb', __dir__)].map { |f| require f }

module Magento
  class << self
    attr_writer :configuration

    delegate :url=, :token=, :store=, :open_timeout=, :timeout=, to: :configuration

    def inflector
      @inflector ||= Dry::Inflector.new do |inflections|
        inflections.singular 'children_data', 'category'
        inflections.singular 'item_applied_taxes', 'item_applied_tax'
        inflections.singular 'applied_taxes', 'applied_tax'
      end
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.with_config(params)
    @old_configuration = configuration
    self.configuration = configuration.copy_with(**params)
    yield
  ensure
    @configuration = @old_configuration
  end

  def self.production?
    ENV['RACK_ENV'] == 'production' ||
      ENV['RAILS_ENV'] == 'production' ||
      ENV['PRODUCTION'] ||
      ENV['production']
  end
end
