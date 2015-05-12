Gem::Specification.new do |gemspec|
  gemspec.name = 'eve_badger'
  gemspec.version = File.read('VERSION')
  gemspec.summary = 'A gem for interacting with the Eve: Online API.'
  gemspec.description = "eve_badger is a simple interface to the Eve: Online API. Unlike other API gems, it returns response data as a badgerfish notation hash, as this is simpler to work with than specific classes for each endpoint. It automatically obeys cache timers with the help of moneta (and redis by default). It also obeys the default request rate limit and will raise an exception rather than make a request that a key's access mask doesn't allow. Please be aware that that eve_badger is a new gem and currently lacks customization options, in addition rough edges."
  gemspec.authors = 'Corey Smedstad'
  gemspec.email = 'smedstadc@gmail.com'
  gemspec.homepage = 'https://github.com/smedstadc/eve_badger'
  gemspec.license = 'MIT'
  gemspec.files = Dir['lib/**/*.*'] + Dir['VERSION'] + Dir['LICENSE'] + Dir['README.md']
  gemspec.required_ruby_version = '>= 1.9.3'
  gemspec.add_runtime_dependency 'nokogiri', '~> 1.6'
  gemspec.add_runtime_dependency 'badgerfish', '~> 0.2.0'
  gemspec.add_runtime_dependency 'slowweb', '~> 0.1.1'
  gemspec.add_runtime_dependency 'moneta', '~> 0.8.0'
  gemspec.add_runtime_dependency 'redis', '~> 3.2', '>= 3.2.0'
  gemspec.add_development_dependency 'rspec', '~> 3'
end
