require 'nokogiri'
require 'open-uri'
require 'slowweb'
require 'time'
require 'badgerfish'
require 'json'
require 'moneta'

module EveBadger
  def self.version
    @version ||= File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'VERSION')))
  end
  def self.user_agent
    @user_agent ||= "EveBadger-#{version}/Ruby-#{RUBY_VERSION}"
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

  class EveAPI
    attr_accessor :user_agent
    attr_reader :key_id, :vcode, :character_id, :access_mask, :key_type

    open(File.expand_path(File.join(File.dirname(__FILE__), '..', 'json', 'account_endpoints.json')), 'r') do |file|
      @@account_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
    end
    open(File.expand_path(File.join(File.dirname(__FILE__), '..', 'json', 'character_endpoints.json')), 'r') do |file|
      @@character_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
    end
    open(File.expand_path(File.join(File.dirname(__FILE__), '..', 'json', 'corporation_endpoints.json')), 'r') do |file|
      @@corporation_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
    end
    open(File.expand_path(File.join(File.dirname(__FILE__), '..', 'json', 'detail_endpoints.json')), 'r') do |file|
      @@detail_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
    end

    begin
      @@request_cache = Moneta.new(:Redis)
    rescue
      @@request_cache = Moneta.new(:File, dir: File.expand_path(File.join(File.dirname(__FILE__), '..', 'cache')))
    end

    def initialize(args={})
      @domain = args[:sisi] ? EveBadger.sisi_domain : EveBadger.tq_domain
      @user_agent = args[:user_agent].to_s || EveBadger.user_agent
      @key_id = args[:key_id].to_s if args[:key_id]
      @vcode = args[:vcode].to_s if args[:vcode]
      @character_id = args[:character_id].to_s if args[:character_id]
      @access_mask = args[:access_mask].to_i if args[:access_mask]
      @key_type = args[:key_type].to_sym if args[:key_type]
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

    def key_type=(type)
      @key_type = type ? type.to_sym : nil
    end

    def account(endpoint_name)
      raise 'missing required key_id or vcode' unless @key_id && @vcode
      endpoint = @@account_endpoint[endpoint_name.to_sym]
      badgerfish_from api_request(endpoint)
    end

    def character(endpoint_name)
      raise 'missing required character_id key_id or_vcode' unless @character_id && @key_id && @vcode
      raise 'wrong key type' unless get_key_type == :Character || :Account
      endpoint = @@character_endpoint[endpoint_name.to_sym]
      badgerfish_from api_request(endpoint)
    end

    def corporation(endpoint_name)
      raise 'missing required character_id key_id or_vcode' unless @character_id && @key_id && @vcode
      raise 'wrong key type' unless get_key_type == :Corporation
      endpoint = @@corporation_endpoint[endpoint_name.to_sym]
      badgerfish_from api_request(endpoint)
    end

    def details(endpoint_name, id_of_interest, fromid=nil, rowcount=nil)
      raise 'wrong key type' unless get_key_type == :Character || :Corporation || :Account
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

    def self.enable_request_cache
      begin
        @@request_cache = Moneta.new(:Redis)
      rescue
        @@request_cache = Moneta.new(:File, dir: File.expand_path(File.join(File.dirname(__FILE__), '..', 'cache')))
      end
    end

    private
    def api_request(endpoint)
      if endpoint_permitted?(endpoint)
        get_response(build_uri(endpoint))
      else
        raise "#{endpoint[:path]} not permitted by access mask"
      end
    end

    def get_key_type
      @key_type ||= account(:api_key_info)['key']['@type'].to_sym
    end

    def endpoint_permitted?(endpoint)
      endpoint[:access_mask].zero? or (get_access_mask & endpoint[:access_mask] != 0)
    end

    def get_access_mask
      @access_mask ||= account(:api_key_info)['key']['@accessMask'].to_i || nil
    end

    def build_uri(endpoint)
      "#{@domain}#{endpoint[:path]}.xml.aspx#{params}"
    end

    def params
        "?keyID=#{@key_id}&vCode=#{@vcode}#{'&characterID=' + @character_id if @character_id}"
    end

    def get_response(uri)
      response = cache_get(uri) || http_get(uri)
      raise_for_api_errors! response
      response
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
        response = error.io.string
      end
      cache_response(uri, response)
      cache_get(uri) || response
    end

    def cache_response(uri, response)
      if @@request_cache
        @@request_cache.store(uri, response, expires: seconds_until_expire(response))
      end
    end

    def seconds_until_expire(xml)
      noko = Nokogiri::XML xml
      cached_until = Time.parse(noko.xpath('//cachedUntil').first.content)
      cached_until.to_i - Time.now.to_i
    end

    def raise_for_api_errors!(response)
      noko = Nokogiri::XML(response)
      if noko.xpath('//error').any?
        raise EveBadger::CCPPleaseError, "#{noko.xpath('//error').first}"
      end
    end

    def badgerfish_from(xml)
      response = Nokogiri::XML(xml)
      Badgerfish::Parser.new.load(response.xpath('//result/*').to_s)
    end
  end

  class CCPPleaseError < StandardError
  end
end
