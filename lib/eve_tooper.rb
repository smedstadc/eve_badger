require 'nokogiri'
require 'open-uri'
require 'slowweb'
require 'time'

module EveTooper
  VERSION = '0.0.1'
  DOMAIN = 'https://api.eveonline.com'
  USER_AGENT = "EveTooper-#{EveTooper::VERSION}/Ruby-#{RUBY_VERSION}"
  SlowWeb.limit(DOMAIN, 29, 60)

  begin
    @request_cache = Marshal.load(File.binread('request_cache.bin'))
    puts "Marshaled cache from disk."
  rescue
    @request_cache = Hash.new
    puts "Created new cache."
  end

  class APIKey
    attr_reader :keyid, :vcode

    def initialize(options={})
      @keyid = options[:keyid].to_s
      @vcode = options[:vcode]
    end

    def account_api_key_info
      # TODO handle "key" xml node too
      {
          key_info: {type: 'FOO', expires: 'BAR', accessmask: 'BAZ'},
          rowset: extract_hashes(EveTooper.get_response("#{EveTooper::DOMAIN}/account/APIKeyInfo.xml.aspx#{params}"))
      }
    end

    def account_characters
      {
          rowset: extract_hashes(EveTooper.get_response("#{EveTooper::DOMAIN}/Account/Characters.xml.aspx#{params}"))
      }
    end

    private
    def params
      "?keyid=#{@keyid}&vcode=#{@vcode}"
    end

    def extract_hashes(xml)
      rowset = Nokogiri::XML(xml)
      # TODO handle output with multiple rowsets
      # TODO maybe use https://github.com/msievers/badgerfish instead of reinventing wheels
      # TODO only return children of result node as hash
      hashes = []
      keys = rowset.xpath("//rowset").first.attr('columns').split(',')
      rowset.xpath("//row").each do |element|
        row_hash = {}
        keys.each do |key|
          row_hash[key.to_sym] = element.attr(key)
        end
        hashes.push(row_hash)
      end
      hashes
    end
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
    File.open('request_cache.bin', 'wb') do |f|
      f.write Marshal.dump(@request_cache)
    end
    @request_cache[uri]
  end
end