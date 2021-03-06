require 'eve_badger/eve_api'
require 'eve_badger/endpoints'
require 'eve_badger/response'
require 'eve_badger/cache'
require 'eve_badger/throttle'

module EveBadger
  def self.version
    @version ||= File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'VERSION'))).chomp
  end

  # provides the default user agent for EveAPI objects, it's a good idea to customize your user agent string to identify your application
  def self.default_user_agent
    "EveBadger-#{EveBadger.version}/Ruby-#{RUBY_VERSION}"
  end

  # provides the default domain for the tranquility (live game server) api
  def self.default_tq_domain
    'https://api.eveonline.com/'
  end

  # provides the detault domain for the singularity (public test server, nicknamed "sisi") api
  def self.default_sisi_domain
    'https://api.testeveonline.com/'
  end
end
