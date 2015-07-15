require 'slowweb'

module EveBadger
  module Throttle
    def self.disable
      SlowWeb.reset
    end

    # enables the default rate limit of 30 requests per minute which ccp expects users to obey
    def self.enable_default
      SlowWeb.limit(EveBadger.default_tq_domain, 30, 60)
      SlowWeb.limit(EveBadger.default_sisi_domain, 30, 60)
    end

    #
    def self.enable_custom(requests_per_minute)
      SlowWeb.reset
      SlowWeb.limit(EveBadger.default_tq_domain, requests_per_minute, 60)
      SlowWeb.limit(EveBadger.default_sisi_domain, requests_per_minute, 60)
    end


    def self.enabled?
     if SlowWeb.get_limit(EveBadger.default_tq_domain) || SlowWeb.get_limit(EveBadger.default_sisi_domain)
       true
     else
       false
     end
    end
  end
end