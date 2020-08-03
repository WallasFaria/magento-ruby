# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'magento/version'

Gem::Specification.new do |s|
  s.name          = 'magento'
  s.version       = Magento::VERSION
  s.date          = '2020-07-31'
  s.summary       = 'Magento Ruby library'
  s.description   = 'Magento Ruby library'
  s.files         = `git ls-files`.split($/)
  s.authors       = ["Wallas Faria"]
  s.email         = 'wallasfaria@hotmail.com'
  s.homepage      = 'https://github.com/WallasFaria/magento-ruby'
  s.require_paths = ['lib']

  s.add_dependency 'http', '~> 4.4'
  s.add_dependency 'dry-inflector', '~> 0.2.0'
end
