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
      @user_agent = value.to_s
    end

    def self.tranquility_domain
      @tranquility_domain ||= URI('https://api.eveonline.com/')
    end

    def self.tranquility_domain= value
      @tranquility_domain = URI(value)
    end

    def self.singularity_domain
      @singularity_domain ||= URI('https://api.testeveonline.com/')
    end

    def self.singularity_domain= value
      @singularity_domain = URI(value)
    end
  end
end
