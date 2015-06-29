require 'spec_helper'
require 'eve_badger/response'

describe EveBadger::Response do
  let(:content) { "<?xml version='1.0' encoding='UTF-8'?>
                   <eveapi version='2'>
                     <currentTime>2015-06-23 21:52:05</currentTime>
                     <result>
                       <name>Eve Badger</name>
                     </result>
                     <cachedUntil>2015-06-23 22:36:37</cachedUntil>
                   </eveapi>" }

  let(:response) { EveBadger::Response.new(content) }

  it "can be created" do
    response.must_be_instance_of EveBadger::Response
  end

  it "returns as xml" do
    response.as_xml.must_be_instance_of String
  end

  it "returns as json" do
    response.as_json.must_be_instance_of Hash
  end

  it "must have expected data when json" do
    response.as_json['eveapi']['result']['name']['$'].must_equal "Eve Badger"
  end

  it "must have expected data when xml" do
    document = Nokogiri::XML(response.as_xml)
    document.xpath("//name").text.must_equal "Eve Badger"
  end

  it "returns only the result as xml" do
    response.result_as_xml.must_equal "<name>Eve Badger</name>"
  end

  it "returns only the result as json" do
    response.result_as_json.must_equal({'name' => {'$' => 'Eve Badger'}})
  end
end
