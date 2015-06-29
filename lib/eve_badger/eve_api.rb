require 'nokogiri'
require 'time'
require 'open-uri'
require 'eve_badger'
require 'eve_badger/endpoints'
require 'eve_badger/response'
require 'eve_badger/cache'
require 'digest/sha1'

module EveBadger
  class EveAPI
    attr_accessor :user_agent
    attr_reader :key_id, :vcode, :character_id, :domain

    def initialize(args={})
      if args[:server] == :sisi
        @domain = EveBadger.sisi_domain
      else
        @domain = EveBadger.tq_domain
      end
      @user_agent = EveBadger.default_user_agent
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

    def access_mask
      @access_mask ||= get_access_mask
    end

    def key_type
      @key_type ||= get_key_type
    end

    def account(endpoint_name)
      raise EveBadger::APIKeyError, 'missing required key_id or vcode' unless @key_id && @vcode
      endpoint = EveBadger::Endpoints.account(endpoint_name.to_sym)
      api_request(endpoint)
    end

    def character(endpoint_name)
      raise EveBadger::APIKeyError, 'missing required character_id key_id or_vcode' unless @character_id && @key_id && @vcode
      raise EveBadger::APIKeyError, 'wrong key type' unless [:Character, :Account].include?(key_type)
      endpoint = EveBadger::Endpoints.character(endpoint_name.to_sym)
      api_request(endpoint)
    end

    def corporation(endpoint_name)
      raise EveBadger::APIKeyError, 'missing required character_id key_id or_vcode' unless @character_id && @key_id && @vcode
      raise EveBadger::APIKeyError, 'wrong key type' unless key_type == :Corporation
      endpoint = EveBadger::Endpoints.corporation(endpoint_name.to_sym)
      api_request(endpoint)
    end

    def details(endpoint_name, id_of_interest, fromid=nil, rowcount=nil)
      raise EveBadger::APIKeyError, 'wrong key type' unless [:Character, :Corporation, :Account].include?(key_type)
      endpoint = EveBadger::Endpoints.detail(endpoint_name.to_sym)
      if endpoint.permitted?(access_mask)
        uri = build_uri(endpoint)
        uri << "&#{endpoint.detail_id}=#{id_of_interest}"
        uri << "&fromID=#{fromid}" if fromid
        uri << "&rowCount=#{rowcount}" if rowcount
        get_response(uri)
      else
        raise EveBadger::APIKeyError, "#{endpoint.path} not permitted by access mask"
      end
    end

    private
    def api_request(endpoint)
      if endpoint.access_mask.zero? or endpoint.permitted?(access_mask)
        get_response(build_uri(endpoint))
      else
        raise EveBadger::APIKeyError, "#{endpoint.path} not permitted by access mask"
      end
    end

    def get_access_mask
      fetch_key_info unless @access_mask
      @access_mask
    end

    def get_key_type
      fetch_key_info unless @key_type
      @key_type
    end

    def fetch_key_info
      info = account(:api_key_info).result_as_json
      @access_mask = info['key']['@accessMask'].to_i
      @key_type = info['key']['@type'].to_sym
    end

    def build_uri(endpoint)
      "#{@domain}#{endpoint.path}.xml.aspx#{params}"
    end

    def params
      "?keyID=#{@key_id}&vCode=#{@vcode}#{"&characterID=#{@character_id}" if @character_id}"
    end

    def get_response(uri)
      response = cache_get(uri) || http_get(uri)
      EveBadger::Response.new(response)
    end

    def cache_get(uri)
      if EveBadger::Cache.enabled?
        EveBadger::Cache.get(hash_of(uri))
      end
    end

    def http_get(uri)
      begin
        response = open(uri) { |res| res.read }
      rescue OpenURI::HTTPError => error
        response = error.io.string
      end
      store_response(uri, response)
      response || cache_get(uri)
    end

    def store_response(uri, response)
      if EveBadger::Cache.enabled?
        EveBadger::Cache.store(hash_of(uri), response, expires: cached_until(response))
      end
    end

    # Hash URI's before use as a cache key so that API key/vcode combinations don't leak from the cache monitor or logs.
    def hash_of(uri)
      Digest::SHA1.hexdigest(uri)
    end

    def cached_until(xml)
      noko = Nokogiri::XML xml
      seconds_until_expire = Time.parse(noko.xpath('//cachedUntil').text)
      seconds_until_expire.to_i - Time.now.to_i
    end
  end

  # Exception to raise when an EveAPI object needs attributes which are missing or invalid.
  class APIKeyError < StandardError
  end
end
