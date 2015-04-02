require './lib/eve_badger'
Gem::Specification.new do |gemspec|
  gemspec.name = 'eve_badger'
  gemspec.version = '0.0.1'
  gemspec.summary = 'A gem that interacts with the Eve: Online API and provides re.'
  gemspec.authors = 'Corey Smedstad'
  gemspec.license = 'MIT'
  gemspec.files = Dir['lib/**/*.rb'] + Dir['json/**/*.json']
  gemspec.required_ruby_version = '>= 1.9.3'
  gemspec.add_runtime_dependency 'nokogiri', '~> 1.6'
  gemspec.add_development_dependency 'rspec', '~> 3'
end
