Gem::Specification.new do |gemspec|
  gemspec.name = 'eve_badger'
  gemspec.version = File.read('VERSION')
  gemspec.summary = 'A gem for interacting with the Eve: Online XML API.'
  gemspec.description = "For more information look at the README in the github repository (homepage link)."
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
end
