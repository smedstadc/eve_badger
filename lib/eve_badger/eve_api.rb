require 'nokogiri'
require 'time'
require 'badgerfish'
require 'open-uri'
require_relative 'endpoint_data'
require_relative 'request_cache'

module EveBadger
  class EveAPI
    attr_accessor :user_agent
    attr_reader :key_id, :vcode, :character_id, :access_mask
    include EveBadger::EndpointData
    include EveBadger::RequestCache

    def initialize(args={})
      @domain = args[:sisi] ? EveBadger.sisi_domain : EveBadger.tq_domain
      @user_agent = EveBadger.user_agent
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

    def key_type
      @key_type ||= get_key_type
    end

    def account(endpoint_name)
      raise 'missing required key_id or vcode' unless @key_id && @vcode
      endpoint = EveAPI.account_endpoint[endpoint_name.to_sym]
      badgerfish_from api_request(endpoint)
    end

    def character(endpoint_name)
      raise 'missing required character_id key_id or_vcode' unless @character_id && @key_id && @vcode
      raise 'wrong key type' unless get_key_type == :Character || :Account
      endpoint = EveAPI.character_endpoint[endpoint_name.to_sym]
      badgerfish_from api_request(endpoint)
    end

    def corporation(endpoint_name)
      raise 'missing required character_id key_id or_vcode' unless @character_id && @key_id && @vcode
      raise 'wrong key type' unless get_key_type == :Corporation
      endpoint = EveAPI.corporation_endpoint[endpoint_name.to_sym]
      badgerfish_from api_request(endpoint)
    end

    def details(endpoint_name, id_of_interest, fromid=nil, rowcount=nil)
      raise 'wrong key type' unless get_key_type == :Character || :Corporation || :Account
      endpoint = EveAPI.detail_endpoint[endpoint_name.to_sym]
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
      if EveAPI.request_cache
        EveAPI.request_cache[uri]
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
      if EveAPI.request_cache
        EveAPI.request_cache.store(uri, response, expires: seconds_until_expire(response))
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
end