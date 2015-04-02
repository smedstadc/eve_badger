require 'nokogiri'
require 'open-uri'
require 'slowweb'
require 'time'
require 'badgerfish'
require 'json'
require 'account_key'
require 'character_key'
require 'eve_api'

module EveTooper
  VERSION = '0.0.1'
  SlowWeb.limit(DOMAIN, 29, 60)


  def self.account_endpoint(name)
    @account_endpoint[name.to_sym].dup
  end

  def self.character_endpoint(name)
    @character_endpoint[name.to_sym].dup
  end
end