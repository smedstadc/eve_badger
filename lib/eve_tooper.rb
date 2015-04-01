require 'nokogiri'
require 'open-uri'
require 'slowweb'
require 'time'
require 'badgerfish'
require 'json'
require 'api_key'

module EveTooper
  VERSION = '0.0.1'
  DOMAIN = 'https://api.eveonline.com/'
  USER_AGENT = "EveTooper-#{EveTooper::VERSION}/Ruby-#{RUBY_VERSION}"
  CACHE_FILE_PATH = 'request_cache.bin'
  PARSER = Badgerfish::Parser.new
  SlowWeb.limit(DOMAIN, 29, 60)

  begin
    @request_cache = Marshal.load(File.binread(CACHE_FILE_PATH))
  rescue
    @request_cache = Hash.new
  end

  private
  def self.get_response(uri)
    if xml_from_cache(uri)
      @xml = Nokogiri::XML(xml_from_cache(uri))
    end

    if Time.now > Time.parse(@xml.xpath("//cachedUntil").first.content)
      xml_from_http(uri)
    else
      xml_from_cache(uri)
    end
  end

  def self.xml_from_cache(uri)
    @request_cache[uri] || xml_from_http(uri)
  end

  def self.xml_from_http(uri)
    open(uri, "User-Agent" => USER_AGENT) do |res|
      @request_cache[uri] = res.read
    end
    File.open(CACHE_FILE_PATH, 'wb') do |f|
      f.write Marshal.dump(@request_cache)
    end
    @request_cache[uri]
  end
end