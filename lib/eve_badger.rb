require 'nokogiri'
require 'open-uri'
require 'slowweb'
require 'time'
require 'badgerfish'
require 'json'

module EveBadger
  VERSION = open('VERSION', 'r').read
  USER_AGENT = "EveBadger-#{VERSION}/Ruby#{RUBY_VERSION}"
  TQ_API_DOMAIN = 'https://api.eveonline.com/'
  SISI_API_DOMAIN = 'https://api.testeveonline.com/'
  CACHE_FILE = './cache/request_cache.bin'
  ACCOUNT_ENDPOINTS_JSON = './json/account_endpoints.json'
  CHARACTER_ENDPOINTS_JSON = './json/character_endpoints.json'
  CORPORATION_ENDPOINTS_JSON = './json/corporation_endpoints.json'
  DETAIL_ENDPOINTS_JSON = './json/detail_endpoints.json'

  # According to CCP the default limit for API access is 30 requests per minute.
  # TODO: Allow this to be changed by people who've made arrangements for higher caps.
  SlowWeb.limit(TQ_API_DOMAIN, 30, 60)
  SlowWeb.limit(SISI_API_DOMAIN, 30, 60)

  class EveAPI
    attr_accessor :key_id, :vcode, :character_id, :access_mask, :user_agent

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

    open(CORPORATION_ENDPOINTS_JSON, 'r') do |file|
      @@corporation_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
    end

    open(DETAIL_ENDPOINTS_JSON, 'r') do |file|
      @@detail_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
    end

    @@request_count = 0
    @@cache_trim_interval = 100

    def initialize(args={})
      @domain = args[:sisi] ? SISI_API_DOMAIN : TQ_API_DOMAIN
      @user_agent = args[:user_agent] || USER_AGENT
      @parser = Badgerfish::Parser.new
      @key_id = args[:key_id].to_s
      @vcode = args[:vcode]
      @character_id = args[:character_id].to_s
      @access_mask = args[:access_mask] || get_access_mask
    end

    def account(endpoint_name)
      raise "missing required key_id or vcode" unless @key_id && @vcode
      endpoint = @@account_endpoint[endpoint_name.to_sym]
      badgerfish_from api_request(endpoint)
    end

    def character(endpoint_name)
      raise "missing required character_id key_id or_vcode" unless @character_id && @key_id && @vcode
      endpoint = @@character_endpoint[endpoint_name.to_sym]
      badgerfish_from api_request(endpoint)
    end

    def corporation(endpoint_name)
      raise "missing required character_id key_id or_vcode" unless @character_id && @key_id && @vcode
      endpoint = @@character_endpoint[endpoint_name.to_sym]
      badgerfish_from api_request(endpoint)
    end

    def details(endpoint_name, id_of_interest, fromid=nil, rowcount=nil)
      endpoint = @@detail_endpoint[endpoint_name.to_sym]
      if endpoint_permitted?(endpoint)
        uri = build_uri(endpoint)
        uri << "&#{endpoint[:detail_id]}=#{id_of_interest}"
        uri << "&fromID=#{fromid}" if fromid
        uri << "&rowCount=#{rowcount}" if rowcount
        badgerfish_from get_response(uri)
      else
        raise "#{endpoint[:path]} not permitted by access mask"
      end
    end

    def dump_cache
      File.open(CACHE_FILE, 'wb') do |f|
        f.write Marshal.dump(@@request_cache)
      end
    end

    private
    def get_access_mask
      self.access_mask = account(:api_key_info)["key"]["@accessMask"].to_i
    end

    def api_request(endpoint)
      EveAPI.trim_cache if EveAPI.trim?
      if endpoint_permitted?(endpoint)
        get_response(build_uri(endpoint))
      else
        raise "#{endpoint[:path]} not permitted by access mask"
      end
    end

    def endpoint_permitted?(endpoint)
      endpoint[:access_mask].zero? or (@access_mask % endpoint[:access_mask] != 0)
    end

    def build_uri(endpoint)
      "#{@domain}#{endpoint[:path]}.xml.aspx#{params}"
    end

    def params
      if @character_id
        "?keyID=#{@key_id}&vCode=#{@vcode}&characterID=#{@character_id}"
      else
        "?keyID=#{@key_id}&vCode=#{@vcode}"
      end
    end

    def get_response(uri)
      if cache_get(uri)
        @xml = Nokogiri::XML(cache_get(uri))
      end

      if Time.now > Time.parse(@xml.xpath("//cachedUntil").first.content)
        http_get(uri)
      else
        cache_get(uri)
      end
    end

    def cache_get(uri)
      @@request_cache[uri] || http_get(uri)
    end

    def http_get(uri)
      @@request_cache[uri] = open(uri) { |res| res.read }
      @@request_cache[uri]
    end

    def badgerfish_from(xml)
      response = Nokogiri::XML(xml)
      if response.xpath("//error").any?
        raise "#{response.xpath("//error").first}"
      end
      @parser.load(response.xpath("//result/*").to_s)
    end

    def self.trim?
      @@request_count += 1
      if @@request_count > @@cache_trim_interval
        @@cache_trim_interval = 0
        true
      end
    end

    def self.trim_cache
      @@request_cache.each do |key, value|
        @@request_cache.delete(key) if cached_until_elapsed?(value)
      end
    end

    def self.cached_until_elapsed?(xml)
      noko = Nokogiri::XML(xml)
      Time.now > Time.parse(noko.xpath("//cachedUntil").first.content)
    end
  end
end
