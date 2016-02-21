require 'eve_badger/version'
require 'eve_badger/eve_api'
require 'eve_badger/endpoints'
require 'eve_badger/response'
require 'eve_badger/cache'

module EveBadger
  module Config
    def self.user_agent
      @user_agent ||= "EveBadger-#{EveBadger.version}/Ruby-#{RUBY_VERSION}"
    end

    def self.user_agent= value
      @user_agent = value
    end

    def self.tranquility_domain
      @tranquility_domain ||= 'https://api.eveonline.com/'
    end

    def self.tranquility_domain= value
      @tranquility_domain = value
    end

    def self.singularity_domain
      @singularity_domain ||= 'https://api.testeveonline.com/'
    end

    def self.singularity_domain= value
      @singularity_domain = value
    end
  end
end
