require 'nokogiri'
require 'open-uri'
require 'slowweb'
require 'time'
require 'badgerfish'
require 'json'
require 'moneta'

module EveBadger
  VERSION = File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'VERSION')))
  USER_AGENT = "EveBadger-#{VERSION}/Ruby-#{RUBY_VERSION}"
  TQ_API_DOMAIN = 'https://api.eveonline.com/'
  SISI_API_DOMAIN = 'https://api.testeveonline.com/'
  CACHE_FILE = File.expand_path(File.join(File.dirname(__FILE__), '..', 'cache', 'moneta'))
  ACCOUNT_ENDPOINTS_JSON = File.expand_path(File.join(File.dirname(__FILE__), '..', 'json', 'account_endpoints.json'))
  CHARACTER_ENDPOINTS_JSON = File.expand_path(File.join(File.dirname(__FILE__), '..', 'json', 'character_endpoints.json'))
  CORPORATION_ENDPOINTS_JSON = File.expand_path(File.join(File.dirname(__FILE__), '..', 'json', 'corporation_endpoints.json'))
  DETAIL_ENDPOINTS_JSON = File.expand_path(File.join(File.dirname(__FILE__), '..', 'json', 'detail_endpoints.json'))

  # According to CCP the default limit for API access is 30 requests per minute.
  SlowWeb.limit(TQ_API_DOMAIN, 30, 60)
  SlowWeb.limit(SISI_API_DOMAIN, 30, 60)

  def self.disable_throttling
    SlowWeb.reset
  end

  def self.enable_default_throttling
    SlowWeb.limit(TQ_API_DOMAIN, 30, 60)
    SlowWeb.limit(SISI_API_DOMAIN, 30, 60)
  end

  def self.enable_custom_throttling(requests_per_minute)
    SlowWeb.reset
    SlowWeb.limit(TQ_API_DOMAIN, requests_per_minute, 60)
    SlowWeb.limit(SISI_API_DOMAIN, requests_per_minute, 60)
  end

  class EveAPI
    attr_accessor :user_agent
    attr_reader :key_id, :vcode, :character_id, :access_mask

    @@request_cache = Moneta.new(:Redis)

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
      @user_agent = args[:user_agent].to_s || USER_AGENT
      @parser = Badgerfish::Parser.new
      @key_id = args[:key_id].to_s if args[:key_id]
      @vcode = args[:vcode].to_s if args[:vcode]
      @character_id = args[:character_id].to_s if args[:character_id]
      @access_mask = args[:access_mask].to_i if args[:access_mask]
    end

    def key_id=(id)
      @key_id = id ? id.to_s : nil
    end

    def vcode=(code)
      @vcode = code ? code.to_s : nil
    end

    def character_id=(id)
      @character_id = id ? id.to_s : nil
    end

    def access_mask=(mask)
      @access_mask = mask ? mask.to_i : nil
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

    def self.disable_request_cache
      @@request_cache = nil
    end

    private
    def api_request(endpoint)
      if endpoint_permitted?(endpoint)
        get_response(build_uri(endpoint))
      else
        raise "#{endpoint[:path]} not permitted by access mask"
      end
    end

    def get_access_mask
      @access_mask ||= account(:api_key_info)["key"]["@accessMask"].to_i
    end

    def endpoint_permitted?(endpoint)
      endpoint[:access_mask].zero? or (get_access_mask & endpoint[:access_mask] != 0)
    end

    def build_uri(endpoint)
      "#{@domain}#{endpoint[:path]}.xml.aspx#{params}"
    end

    def params
      if @character_id
        "?keyID=#{@key_id}&vCode=#{@vcode}#{"&characterID=" + @character_id if @character_id}"
      end
    end

    def get_response(uri)
      cache_get(uri) || http_get(uri)
    end

    def cache_get(uri)
      if @@request_cache
        @@request_cache[uri]
      end
    end

    def http_get(uri)
      begin
        response = open(uri) { |res| res.read }
      rescue OpenURI::HTTPError => error
        raise "HTTPError during API request #{error}"
      end
      if @@request_cache
        @@request_cache.store(uri, response, expires: seconds_until_expire(response))
        @@request_cache[uri]
      else
        response
      end
    end

    def seconds_until_expire(xml)
      noko = Nokogiri::XML xml
      cached_until = Time.parse(noko.xpath("//cachedUntil").first.content)
      cached_until.to_i - Time.now.to_i
    end

    def badgerfish_from(xml)
      response = Nokogiri::XML(xml)
      if response.xpath("//error").any?
        raise "#{response.xpath("//error").first}"
      end
      @parser.load(response.xpath("//result/*").to_s)
    end
  end
end
