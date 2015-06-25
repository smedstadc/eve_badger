require 'spec_helper'
require 'eve_badger/response'

describe EveBadger::Response do
  before do
    @content = "
    <?xml version='1.0' encoding='UTF-8'?>
    <eveapi version='2'>
      <currentTime>2015-06-23 21:52:05</currentTime>
      <result>
        <name>Eve Badger</name>
      </result>
      <cachedUntil>2015-06-23 22:36:37</cachedUntil>
    </eveapi>"
  end

  it "can be created" do
    EveBadger::Response.new(@content).must_be_instance_of EveBadger::Response
  end

  it "returns as xml" do
    EveBadger::Response.new(@content).as_xml.must_be_instance_of String
  end

  it "returns json" do
    EveBadger::Response.new(@content).as_json.must_be_instance_of Hash
  end
end
