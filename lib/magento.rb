# frozen_string_literal: true

require 'time'

require_relative 'magento/error'
require_relative 'magento/request'
require_relative 'magento/model'
require_relative 'magento/product'

Dir[File.expand_path('magento/product/*.rb', __dir__)].map do |path|
  require path
end

module Magento
  class << self
    attr_accessor :url, :open_timeout, :timeout, :token
  end

  self.url            = ENV['MAGENTO_URL']
  self.open_timeout   = 30
  self.timeout        = 90
  self.token          = ENV['MAGENTO_TOKEN']

  def self.production?
    ENV['RACK_ENV'] == 'production' ||
      ENV['RAILS_ENV'] == 'production' ||
      ENV['PRODUCTION'] ||
      ENV['production']
  end
end
