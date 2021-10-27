# frozen_string_literal: true

require_relative './lib/dennis/version'

Gem::Specification.new do |s|
  s.name          = 'dennis-client'
  s.description   = 'A client library for talking to the Dennis DNS API.'
  s.summary       = s.description
  s.homepage      = 'https://github.com/krystal/dennis-client'
  s.version       = Dennis::VERSION
  s.licenses      = ['MIT']
  s.files         = Dir.glob('VERSION') + Dir.glob('{lib}/**/*')
  s.require_paths = ['lib']
  s.authors       = ['Adam Cooke']
  s.email         = ['adam@krystal.uk']
  s.add_runtime_dependency 'apia-client'
  s.required_ruby_version = '>= 2.5'
end
