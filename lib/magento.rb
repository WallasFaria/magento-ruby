# frozen_string_literal: true

require 'time'

require_relative 'magento/errors'
require_relative 'magento/request'
require_relative 'magento/model'
require_relative 'magento/product'
require_relative 'magento/country'

Dir[File.expand_path('magento/product/*.rb', __dir__)].map { |f| require f }
Dir[File.expand_path('magento/country/*.rb', __dir__)].map { |f| require f }

module Magento
  class << self
    attr_accessor :url, :open_timeout, :timeout, :token, :store
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
