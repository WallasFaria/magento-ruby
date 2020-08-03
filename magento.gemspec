# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name          = 'magento'
  s.version       = '0.3.1'
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
