require 'bundler/setup'
require 'byebug'
require 'magento'
require 'vcr'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.filter_sensitive_data('<MAGENTO_URL>') { ENV['MAGENTO_URL'] }
  c.filter_sensitive_data('<MAGENTO_DOMAIN>') { ENV['MAGENTO_URL'].to_s.sub(/^http(s)?:\/\//, '') }
  c.filter_sensitive_data('<MAGENTO_TOKEN>') { ENV['MAGENTO_TOKEN'] }
end
