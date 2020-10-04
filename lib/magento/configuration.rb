module Magento
  class Configuration
    attr_accessor :url, :open_timeout, :timeout, :token, :store
  
    def initialize(url: nil, token: nil, store: nil)
      self.url            = url || ENV['MAGENTO_URL']
      self.open_timeout   = 30
      self.timeout        = 90
      self.token          = token || ENV['MAGENTO_TOKEN']
      self.store          = store || ENV['MAGENTO_STORE'] || :all
    end
  
    def copy_with(params = {})
      clone.tap do |config|
        params.each { |key, value| config.send("#{key}=", value) }
      end
    end
  end
end
