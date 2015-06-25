require 'spec_helper'
require 'eve_badger/eve_api'

describe EveBadger::EveAPI do
  before do
    @key_id = '2641361'
    @vcode = 'H7MGidb2MB7MzqPvqOOz7RtdjEyY4dHTP8u8Ojf7ywUOQ7MC8RQFRvSDQuFaX02R'
    @char_id = '93772629'
    @mask = '26091848'
    @type = 'Character'
  end

  it "should get a response" do
    key = EveBadger::EveAPI.new(key_id: @key_id, vcode: @vcode)
    key.account(:api_key_info).must_be_instance_of EveBadger::Response
  end
end
