# frozen_string_literal: true

require 'time'
require 'dry/inflector'

require_relative 'magento/errors'
require_relative 'magento/request'
require_relative 'magento/model'
require_relative 'magento/model_mapper'
require_relative 'magento/record_collection'
require_relative 'magento/query'
require_relative 'magento/category'
require_relative 'magento/product'
require_relative 'magento/country'
require_relative 'magento/customer'
require_relative 'magento/order'

Dir[File.expand_path('magento/shared/*.rb', __dir__)].map { |f| require f }

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

  def self.production?
    ENV['RACK_ENV'] == 'production' ||
      ENV['RAILS_ENV'] == 'production' ||
      ENV['PRODUCTION'] ||
      ENV['production']
  end
end
