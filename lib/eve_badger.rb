require 'eve_badger/eve_api'
require 'eve_badger/endpoints'
require 'eve_badger/response'
require 'eve_badger/cache'
require 'eve_badger/throttle'

module EveBadger
  def self.version
    @version ||= File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'VERSION'))).chomp
  end

  def self.default_user_agent
    "EveBadger-#{EveBadger.version}/Ruby-#{RUBY_VERSION}"
  end

  def self.default_tq_domain
    'https://api.eveonline.com/'
  end

  def self.default_sisi_domain
    'https://api.testeveonline.com/'
  end
end
