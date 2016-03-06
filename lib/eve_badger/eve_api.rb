require 'nokogiri'
require 'time'
require 'open-uri'
require 'digest/sha1'

module EveBadger
  class EveAPI
    attr_accessor :user_agents
    attr_reader :key_id, :vcode, :character_id, :domain

    def initialize(args={})
      @domain = args[:sisi] ? EveBadger::Config.singularity_domain : EveBadger::Config.tranquility_domain
      @user_agent = EveBadger::Config.user_agent
      @key_id = args[:key_id].to_s if args[:key_id]
      @vcode = args[:vcode].to_s if args[:vcode]
      @character_id = args[:character_id].to_s if args[:character_id]
      @access_mask = args[:access_mask].to_i if args[:access_mask]
      @key_type = args[:key_type].to_sym if args[:key_type]
    end

    # sets key_it, coerces to string
    def key_id=(id)
      @key_id = id ? id.to_s : nil
    end

    # sets vcode, coerces to string
    def vcode=(code)
      @vcode = code ? code.to_s : nil
    end

    # sets character_id, coerces to string
    def character_id=(id)
      @character_id = id ? id.to_s : nil
    end

    # sets access_mask, coerces to integer
    def access_mask=(mask)
      @access_mask = mask ? mask.to_i : nil
    end

    # sets key_type, coerces to symbol
    def key_type=(type)
      @key_type = type ? type.to_sym : nil
    end

    # access or retrieve access_mask, will also set key_type if an automatic fetch is triggered
    def access_mask
      @access_mask ||= get_access_mask
    end

    # access or retrieve key_type, will also set access_mask if an automatic fetch is triggered
    def key_type
      @key_type ||= get_key_type
    end

    # takes an account endpoint name and returns a response object, raises an APIKeyError if the request would fail
    def account(endpoint_name)
      raise EveBadger::APIKeyError, 'missing required key_id or vcode' unless @key_id && @vcode
      endpoint = EveBadger::Endpoints.account(endpoint_name.to_sym)
      api_request(endpoint)
    end

    # takes a character endpoint name and returns a response object, raises an APIKeyError if the request would fail
    def character(endpoint_name)
      raise EveBadger::APIKeyError, 'missing required character_id key_id or_vcode' unless @character_id && @key_id && @vcode
      raise EveBadger::APIKeyError, 'wrong key type' unless [:Character, :Account].include?(key_type)
      endpoint = EveBadger::Endpoints.character(endpoint_name.to_sym)
      api_request(endpoint)
    end

    # takes a corporation endpoint name and returns a response object, raises an APIKeyError if the request would fail
    def corporation(endpoint_name)
      raise EveBadger::APIKeyError, 'missing required character_id key_id or_vcode' unless @character_id && @key_id && @vcode
      raise EveBadger::APIKeyError, 'wrong key type' unless key_type == :Corporation
      endpoint = EveBadger::Endpoints.corporation(endpoint_name.to_sym)
      api_request(endpoint)
    end

    # takes a detail endpoint name and id of interest then returns a response from the given endpoint name, raises an APIKeyError if the request would fail
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
    # takes an endpoint hash and makes an api request to it, raises an APIKeyError if the request would fail
    def api_request(endpoint)
      if endpoint.access_mask.zero? or endpoint.permitted?(access_mask)
        get_response(build_uri(endpoint))
      else
        raise EveBadger::APIKeyError, "#{endpoint.path} not permitted by access mask"
      end
    end

    # returns the access mask for a key and will retrieve it if not present
    def get_access_mask
      fetch_key_info unless @access_mask
      @access_mask
    end

    # returns api key type as a symbol example: :Account, :Character, :Corporation
    def get_key_type
      fetch_key_info unless @key_type
      @key_type
    end

    # sets @access_mask and @key_type from the public :api_key_info endpoint
    def fetch_key_info
      info = account(:api_key_info).result_as_json
      @access_mask = info['key']['@accessMask'].to_i
      @key_type = info['key']['@type'].to_sym
    end

    # builds a uri string for a given endpoint
    def build_uri(endpoint)
      uri = URI(@domain)
      uri.path = "#{endpoint.path}.xml.aspx"
      uri.query = params
      uri
    end

    # builds the default params string for most requests

    def base_params
      params_hash = {'keyID' => @key_id, 'vCode' => @vcode}
      params_hash.merge!('characterID' => @character_id) if @character_id
      params_hash
    end

    def params
      URI.encode_www_form base_params
    end

    # attempts to get a http response from the request cache first, then makes an http request if not found
    def get_response(uri)
      response = cache_get(uri) || http_get(uri)
      EveBadger::Response.new(response)
    end

    # get an http response from the cache if is enabled, returns nil if expired or not found
    def cache_get(uri)
      if EveBadger::Cache.enabled?
        EveBadger::Cache.get(hash_of(uri))
      end
    end

    # get a uri via http
    def http_get(uri)
      begin
        response = open(uri, "User-Agent" => @user_agent) { |res| res.read }
      rescue OpenURI::HTTPError => error
        response = error.io.string
      end
      store_response(uri, response)
      response || cache_get(uri)
    end

    # store an http response in the cache if it is enabled
    def store_response(uri, response)
      if EveBadger::Cache.enabled?
        EveBadger::Cache.store(hash_of(uri), response, expires: cached_until(response))
      end
    end

    # Hash URI's before use as a cache key so that API key/vcode combinations don't leak into log files
    def hash_of(uri)
      Digest::SHA1.hexdigest(uri.to_s)
    end

    # returns the number of seconds until the cachedUntil value in the xml response from the the API
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
