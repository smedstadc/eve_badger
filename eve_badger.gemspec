$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'eve_badger/version'

Gem::Specification.new do |gemspec|
  gemspec.name = 'eve_badger'
  gemspec.version = EveBadger.version
  gemspec.summary = 'An Eve: Online API gem.'
  gemspec.description = 'Easily get XML or JSON from the Eve: Online API with optional caching.'
  gemspec.authors = 'Corey Smedstad'
  gemspec.email = 'smedstadc@gmail.com'
  gemspec.homepage = 'https://github.com/smedstadc/eve_badger'
  gemspec.license = 'MIT'
  gemspec.files = Dir['lib/**/*.*'] + Dir['LICENSE'] + Dir['README.md']
  gemspec.required_ruby_version = '>= 1.9.3'
  gemspec.add_runtime_dependency 'nokogiri', '~> 1.6'
  gemspec.add_runtime_dependency 'badgerfish', '~> 0.2.0'
  gemspec.add_runtime_dependency 'moneta', '~> 0.8.0'
  gemspec.add_development_dependency 'minitest', '~> 5.7'
  gemspec.add_development_dependency 'rake'
end
