require 'moneta'
require 'digest/sha1'

module EveBadger
  module Cache
    @cache = Moneta.new(:File, dir: File.expand_path(File.join(File.dirname(__FILE__), 'cache')), expires: true)

    def self.enable!
      @cache = Moneta.new(:File, dir: File.expand_path(File.join(File.dirname(__FILE__), 'cache')), expires: true)
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
