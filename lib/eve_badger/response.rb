require 'badgerfish'
require 'nokogiri'
require 'time'

module EveBadger
  class Response
    def initialize(content)
      @content = content
    end

    # returns the response content as ruby hash representing badgerfish notation JSON
    def as_json
      Badgerfish::Parser.new.load(@content)
    end

    # returns the response content as raw XML which you can feed into your favorite parser
    def as_xml
      @content
    end

    # same as #as_xml, but only returns the content of the <result> tag
    def result_as_xml
      Nokogiri::XML(@content).xpath("//result/*").to_s
    end

    # same as #as_json, but only returns the content of the <result> tag
    def result_as_json
      Badgerfish::Parser.new.load(@content)['eveapi']['result']
    end

    # fetch any <error> tag in the document, helpful for api error checking
    def api_errors
      document = Nokogiri::XML(@content)
      document.xpath('//error')
    end
  end

  # Exception to raise when the Eve API returns an error code in the response.
  class CCPPleaseError < StandardError
  end
end
