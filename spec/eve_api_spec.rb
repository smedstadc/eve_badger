require 'spec_helper'
require 'eve_badger/eve_api'

describe EveBadger::EveAPI do
  let(:keyID) { '2641361' }
  let(:vcode) { 'H7MGidb2MB7MzqPvqOOz7RtdjEyY4dHTP8u8Ojf7ywUOQ7MC8RQFRvSDQuFaX02R' }
  let(:characterID) { '93772629' }
  let(:accessMask) { '26091848' }
  let(:keyType) { 'Character' }

  it "should get a response" do
    key = EveBadger::EveAPI.new(key_id: keyID, vcode: vcode)
    key.account(:api_key_info).must_be_instance_of EveBadger::Response
  end
end
