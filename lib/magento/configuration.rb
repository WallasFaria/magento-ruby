module Magento
  class Configuration
    attr_accessor :url, :open_timeout, :timeout, :token, :store, :product_image
  
    def initialize(url: nil, token: nil, store: nil)
      self.url            = url || ENV['MAGENTO_URL']
      self.open_timeout   = 30
      self.timeout        = 90
      self.token          = token || ENV['MAGENTO_TOKEN']
      self.store          = store || ENV['MAGENTO_STORE'] || :all

      self.product_image  = ProductImageConfiguration.new
    end
  
    def copy_with(params = {})
      clone.tap do |config|
        params.each { |key, value| config.send("#{key}=", value) }
      end
    end
  end

  class ProductImageConfiguration
    attr_accessor :small_size, :medium_size, :large_size

    def initialize
      self.small_size  = '200x200>'
      self.medium_size = '400x400>'
      self.large_size  = '800x800>'
    end
  end
end
