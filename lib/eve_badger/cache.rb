require 'moneta'
require 'digest/sha1'

module EveBadger
  module Cache
    # Cache is disabled by default
    @cache = nil

    # EveBadger uses the moneta gem to handle caching. Enable caching by passing any Moneta object to .enable!
    # Remember to pass the 'expires: true' option for the :Memory and :File cache types or EveBadger won't invalidate
    # cache values older than their cachedUntil timestamps.
    def self.enable!(handler=Moneta.new(:Memory, expires: true))
      if [Moneta::Transformer::MarshalPrefixKeyMarshalValue, Moneta::Expires].include? handler.class
        @cache = handler
      else
        raise ArgumentError, "handler must be a Moneta object"
      end
    end

    def self.disable!
      @cache = nil
    end

    def self.enabled?
      @cache ? true : false
    end

    def self.store(key, value, options={})
      if @cache
        @cache.store(key, value, options)
      else
        raise "Cannot store when cache is disabled."
      end
    end

    def self.get(key)
      if @cache
        @cache[key]
      else
        raise "Cannot get when cache is disabled."
      end
    end
  end
end
