require './lib/eve_badger'
Gem::Specification.new do |gemspec|
  gemspec.name = 'eve_badger'
  gemspec.version = EveBadger::VERSION
  gemspec.summary = 'A gem for interacting with the Eve: Online API.'
  gemspec.authors = 'Corey Smedstad'
  gemspec.license = 'MIT'
  gemspec.files = Dir['lib/**/*.rb'] + Dir['json/**/*.json'] + Dir['VERSION'] + Dir['LICENSE']
  gemspec.required_ruby_version = '>= 1.9.3'
  gemspec.add_runtime_dependency 'nokogiri', '~> 1.6'
  gemspec.add_runtime_dependency 'badgerfish', '~> 0.2.0'
  gemspec.add_runtime_dependency 'slowweb', '~> 0.1.1'
  gemspec.add_runtime_dependency 'moneta', '~> 0.8.0'
  gemspec.add_runtime_dependency 'redis', '~> 3.2', '>= 3.2.0'
  gemspec.add_development_dependency 'rspec', '~> 3'
end
