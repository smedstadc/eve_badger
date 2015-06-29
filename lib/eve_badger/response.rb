require 'badgerfish'
require 'nokogiri'
require 'time'

module EveBadger
  class Response
    def initialize(content)
      @content = content
    end

    # returns json in badgerfish notation
    def as_json
      Badgerfish::Parser.new.load(@content)
    end

    # returns the response content as xml string
    def as_xml
      @content
    end

    # same as #as_xml but truncates to just <result> data
    def result_as_xml
      Nokogiri::XML(@content).xpath("//result/*").to_s
    end

    # same as #as_json but truncates to just <result> data
    def result_as_json
      Badgerfish::Parser.new.load(@content)['eveapi']['result']
    end

    # raise an exception if the response contains an Eve API error
    def raise_for_api_errors!(response)
      document = Nokogiri::XML(response)
      if document.xpath('//error').any?
        raise EveBadger::CCPPleaseError, "#{document.xpath('//error').first}"
      end
    end
  end

  # Exception to raise when the Eve API returns an error code in the response.
  class CCPPleaseError < StandardError
  end
end
