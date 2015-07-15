require 'moneta'
require 'digest/sha1'

module EveBadger
  # A wrapper around a Moneta object that provides automatic request caching for Evebadger::EveAPI while enabled.
  module Cache
    # Cache is disabled by default
    @cache = nil
    # These adapters support expiration natively and don't need to be wrapped in Moneta::Expires
    @native_expires = [:Mongo, :MongoOfficial, :MongoMoped, :Redis, :Cassandra, :MemcachedDalli, :Memcached, :MemcachedNative, :Cookie]

    # Enable the cache with a specified Moneta adapter.
    # See Moneta API documentation for possible configurations: http://www.rubydoc.info/gems/moneta/frames
    def self.enable(*args, **kwargs)
      unless @native_expires.any? { |name| args.include?(name) }
        kwargs.merge!({expires: true})
      end
      @cache = Moneta.new(*args, **kwargs)
    end

    def self.disable
      @cache = nil
    end

    def self.enabled?
      @cache ? true : false
    end

    def self.type
      @cache.class
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
