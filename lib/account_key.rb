module EveTooper
  class AccountKey
    attr_reader :keyid, :vcode

    def initialize(args={})
      @keyid = args[:keyid].to_s
      @vcode = args[:vcode]
      initialize_hook(args)
    end

    def initialize_hook(args)
      nil
    end

    # def account_api_key_info
    #   extract_hash from: endpoint_request('account/APIKeyInfo')
    # end
    #
    # def account_characters
    #   extract_hash from: endpoint_request('Account/Characters')
    # end

    private
    def endpoint_request(endpoint_name)
      EveTooper.get_response "#{EveTooper::DOMAIN}#{endpoint_name}.xml.aspx#{params}"
    end

    def params
      "?keyid=#{@keyid}&vcode=#{@vcode}"
    end

    def extract_hash(args={})
      response = Nokogiri::XML(args[:from])
      EveTooper::PARSER.load(response.xpath("//result/*").to_s)
    end
  end
end
