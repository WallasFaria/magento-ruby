# frozen_string_literal: true

require 'time'
require 'dry/inflector'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash/keys'

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
require_relative 'magento/import'

Dir[File.expand_path('magento/shared/*.rb', __dir__)].map { |f| require f }
Dir[File.expand_path('magento/params/*.rb', __dir__)].map { |f| require f }

module Magento
  class << self
    attr_accessor :url, :open_timeout, :timeout, :token, :store

    def inflector
      @inflector ||= Dry::Inflector.new do |inflections|
        inflections.singular 'children_data', 'category'
      end
    end
  end

  self.url            = ENV['MAGENTO_URL']
  self.open_timeout   = 30
  self.timeout        = 90
  self.token          = ENV['MAGENTO_TOKEN']
  self.store          = ENV['MAGENTO_STORE'] || :all

  def self.with_config(url: Magento.url, token: Magento.token, store: Magento.store)
    @old_url   = self.url
    @old_token = self.token
    @old_store = self.store

    self.url   = url
    self.token = token
    self.store = store

    yield
  ensure
    self.url   = @old_url
    self.token = @old_token
    self.store = @old_store
  end

  def self.production?
    ENV['RACK_ENV'] == 'production' ||
      ENV['RAILS_ENV'] == 'production' ||
      ENV['PRODUCTION'] ||
      ENV['production']
  end
end
