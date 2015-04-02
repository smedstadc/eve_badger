require 'nokogiri'
require 'open-uri'
require 'slowweb'
require 'time'
require 'badgerfish'
require 'json'

module EveBadger
  VERSION = '0.0.1'
  USER_AGENT = "EveBadger-#{VERSION}/Ruby#{RUBY_VERSION}"
  TQ_API_DOMAIN = 'https://api.eveonline.com/'
  SISI_API_DOMAIN = 'https://api.testeveonline.com/'
  CACHE_FILE = './cache/request_cache.bin'
  ACCOUNT_ENDPOINTS_JSON = './json/account_endpoints.json'
  CHARACTER_ENDPOINTS_JSON = './json/character_endpoints.json'

  # According to CCP the default limit for API access is 30 requests per minute.
  # TODO: Allow this to be changed by people who've made arrangements for higher caps.
  SlowWeb.limit(TQ_API_DOMAIN, 30, 60)
  SlowWeb.limit(SISI_API_DOMAIN, 30, 60)

  class EveApi
    attr_accessor :key_id, :vcode, :character_id

    begin
      @@request_cache = Marshal.load(File.binread(CACHE_FILE))
    rescue
      @@request_cache = Hash.new
    end

    open(ACCOUNT_ENDPOINTS_JSON, 'r') do |file|
      @@account_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
    end

    open(CHARACTER_ENDPOINTS_JSON, 'r') do |file|
      @@character_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
    end

    def initialize(args={})
      @parser = Badgerfish::Parser.new
      @user_agent = args[:user_agent] || USER_AGENT
      @domain = args[:sisi] ? SISI_API_DOMAIN : TQ_API_DOMAIN
      @key_id = args[:key_id].to_s
      @vcode = args[:vcode]
      @access_mask = args[:access_mask]
      @character_id = args[:character_id].to_s
    end

    def account(endpoint_name)
      endpoint = @@account_endpoint[endpoint_name.to_sym].dup
      uri = build_uri endpoint
      response = get_response uri
      badgerfish_from response
    end

    def character(endpoint_name)
      endpoint = @@character_endpoint[endpoint_name.to_sym].dup
      uri = build_uri endpoint
      response = get_response uri
      badgerfish_from response
    end

    def dump_cache
      File.open(CACHE_FILE, 'wb') do |f|
        f.write Marshal.dump(@@request_cache)
      end
    end

    private
    def build_uri(endpoint)
      @domain + endpoint[:path] + '.xml.aspx' + params
    end

    def params
      if @character_id
        "?keyid=#{@key_id}&vcode=#{@vcode}&characterid=#{@character_id}"
      else
        "?keyid=#{@key_id}&vcode=#{@vcode}"
      end
    end

    def get_response(uri)
      if cache_get(uri)
        @xml = Nokogiri::XML(cache_get(uri))
      end

      if Time.now > Time.parse(@xml.xpath('//cachedUntil').first.content)
        http_get(uri)
      else
        cache_get(uri)
      end
    end

    def cache_get(uri)
      @@request_cache[uri] || http_get(uri)
    end

    def http_get(uri)
      open(uri) do |res|
        @@request_cache[uri] = res.read
      end
      @@request_cache[uri]
    end

    def badgerfish_from(xml)
      response = Nokogiri::XML(xml)
      @parser.load(response.xpath("//result/*").to_s)
    end
  end
end





