require './lib/eve_tooper'
Gem::Specification.new do |gemspec|
  gemspec.name = 'eve_tooper'
  gemspec.version = EveTooper::VERSION
  gemspec.summary = 'A gem for interacting with the Eve: Online API.'
  gemspec.authors = 'Corey Smedstad'
  gemspec.license = 'MIT'
  gemspec.files = Dir['lib/**/*.rb']
  gemspec.required_ruby_version = '>= 1.9.3'
  gemspec.add_runtime_dependency 'nokogiri', '~> 1.6'
  gemspec.add_development_dependency 'rspec', '~> 3'
end
