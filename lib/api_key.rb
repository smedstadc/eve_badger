module EveTooper
  class APIKey
    attr_reader :keyid, :vcode

    def initialize(options={})
      @keyid = options[:keyid].to_s
      @vcode = options[:vcode]
    end

    def account_api_key_info
      extract_hash from: request('account/APIKeyInfo')
    end

    def account_characters
      extract_hash from: request('Account/Characters')
    end

    private
    def request(path)
      EveTooper.get_response "#{EveTooper::DOMAIN}#{path}.xml.aspx#{params}"
    end

    def params
      "?keyid=#{@keyid}&vcode=#{@vcode}"
    end

    def extract_hash(options={})
      response = Nokogiri::XML(options[:from])
      EveTooper::PARSER.load(response.xpath("//result/*").to_s)
    end
  end
end
