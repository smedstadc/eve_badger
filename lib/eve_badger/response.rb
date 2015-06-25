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

    def raise_for_api_errors!(response)
      document = Nokogiri::XML(response)
      if document.xpath('//error').any?
        raise "#{document.xpath('//error').first}"
      end
    end
  end
end
