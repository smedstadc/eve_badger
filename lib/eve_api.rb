module EveTooper
  class EveApi
    def initialize(args={})
      load_cache
      load_endpoints
      @parser = Badgerfish::Parser.new
      @user_agent = args[:user_agent] || "EveTooper-#{EveTooper::VERSION}/Ruby-#{RUBY_VERSION}"

      case args[:server]
        when :tq
          @domain = 'https://api.eveonline.com/'
        when :sisi
          @domain = 'https://api.testeveonline.com/'
        else
          @domain = 'https://api.eveonline.com/'
      end
    end

    private
    def load_cache
      begin
        @request_cache = Marshal.load(File.binread('./cache/request_cache.bin'))
      rescue
        @request_cache = Hash.new
      end
    end

    def dump_cache
      File.open('./cache/request_cache.bin', 'wb') do |f|
        f.write Marshal.dump(@request_cache)
      end
    end

    def load_endpoints
      open('./json/account_endpoints.json', 'r') do |file|
        @account_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
      end

      open('./json/character_endpoints.json', 'r') do |file|
        @character_endpoint = JSON.parse(file.read.to_s, :symbolize_names => true)
      end
    end

    def get_response(uri)
      if xml_from_cache(uri)
        @xml = Nokogiri::XML(xml_from_cache(uri))
      end

      if Time.now > Time.parse(@xml.xpath('//cachedUntil').first.content)
        xml_from_http(uri)
      else
        xml_from_cache(uri)
      end
    end

    def xml_from_cache(uri)
      @request_cache[uri] || xml_from_http(uri)
    end

    def xml_from_http(uri)
      open(uri, 'User-Agent' => @user_agent) do |res|
        @request_cache[uri] = res.read
      end
      @request_cache[uri]
    end
  end
end