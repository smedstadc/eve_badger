require 'slowweb'
require 'eve_badger/eve_api'

module EveBadger
  def self.version
    @version ||= File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'VERSION')))
  end
  def self.user_agent
    "EveBadger-#{EveBadger.version}/Ruby-#{RUBY_VERSION}"
  end
  def self.tq_domain
    'https://api.eveonline.com/'
  end
  def self.sisi_domain
    'https://api.testeveonline.com/'
  end

  # According to CCP the default limit for API access is 30 requests per minute.
  SlowWeb.limit(tq_domain, 30, 60)
  SlowWeb.limit(sisi_domain, 30, 60)

  def self.disable_throttling
    SlowWeb.reset
  end

  def self.enable_default_throttling
    SlowWeb.limit(@tq_domain, 30, 60)
    SlowWeb.limit(@sisi_domain, 30, 60)
  end

  def self.enable_custom_throttling(requests_per_minute)
    SlowWeb.reset
    SlowWeb.limit(@tq_domain, requests_per_minute, 60)
    SlowWeb.limit(@sisi_domain, requests_per_minute, 60)
  end

  class CCPPleaseError < StandardError
  end
end
