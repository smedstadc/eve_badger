require 'eve_badger/version'
require 'eve_badger/eve_api'
require 'eve_badger/endpoints'
require 'eve_badger/response'
require 'eve_badger/cache'

module EveBadger
  module Config
    def self.default_user_agent
      "EveBadger-#{EveBadger.version}/Ruby-#{RUBY_VERSION}"
    end

    # provides the default domain for the tranquility (live game server) api
    def self.default_tq_domain
      'https://api.eveonline.com/'
    end

    # provides the default domain for the singularity (public test server, nicknamed "sisi") api
    def self.default_sisi_domain
      'https://api.testeveonline.com/'
    end
  end
end
