require 'moneta'

module EveBadger
  module RequestCache
    def self.included(base)
      base.extend(RequestCache)
    end

    module RequestCache
      @@request_cache = Moneta.new(:File, dir: File.expand_path(File.join(File.dirname(__FILE__), 'cache')))

      def request_cache
        @@request_cache
      end

      def disable_request_cache
        @@request_cache = nil
      end

      def enable_request_cache
        @@request_cache = Moneta.new(:File, dir: File.expand_path(File.join(File.dirname(__FILE__), 'cache')))
      end
    end
  end
end
