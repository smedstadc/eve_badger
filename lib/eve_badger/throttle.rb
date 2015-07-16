require 'slowweb'

module EveBadger
  module Throttle
    # disable request throttling
    def self.disable
      SlowWeb.reset
    end

    # enables the default rate limit of 30 requests per second
    def self.enable_default
      SlowWeb.limit(EveBadger.default_tq_domain, 30, 1)
      SlowWeb.limit(EveBadger.default_sisi_domain, 30, 1)
    end

    # set a custom rate limit if ccp has granted your application an exception
    def self.enable_custom(requests_per_second)
      SlowWeb.reset
      SlowWeb.limit(EveBadger.default_tq_domain, requests_per_second, 1)
      SlowWeb.limit(EveBadger.default_sisi_domain, requests_per_second, 1)
    end

    # test if request throttling is currently enabled
    def self.enabled?
     if SlowWeb.get_limit(EveBadger.default_tq_domain) || SlowWeb.get_limit(EveBadger.default_sisi_domain)
       true
     else
       false
     end
    end
  end
end
