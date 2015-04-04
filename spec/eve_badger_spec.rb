require 'spec_helper'

describe "EveBadger" do
  before(:each) do
    @api = EveBadger::EveAPI.new(server: :tq,
                                 key_id: 2641361,
                                 vcode: 'H7MGidb2MB7MzqPvqOOz7RtdjEyY4dHTP8u8Ojf7ywUOQ7MC8RQFRvSDQuFaX02R',
                                 character_id: 91543956,
    )
  end

  after(:all) do
    @api.dump_cache
  end

  it "should make EveAPI objects with keyid and vcode" do
    expect(@api.key_id).to eq('2641361')
    expect(@api.vcode).to eq('H7MGidb2MB7MzqPvqOOz7RtdjEyY4dHTP8u8Ojf7ywUOQ7MC8RQFRvSDQuFaX02R')
    expect(@api.character_id).to eq('91543956')
  end

  it "should get accessmask automatically when not explicitly provided" do
    expect(@api.access_mask).to_not be_nil
  end

  it "should get api key info" do
    response = @api.account(:api_key_info)
    expect(response['key']).to_not be_nil
  end

  it "should get list of characters" do
    response = @api.account(:list_of_characters)
    response['rowset']['row'].each do |row|
      expect(row['@name']).to_not be_nil
    end
  end

  it "should get skill in training" do
    response = @api.character(:skill_in_training)
    expect(response['currentTQTime']['$']).to_not be_nil
  end

  it "account endpoints should raise when missing vcode" do
    @api.vcode = nil
    expect { @api.account(:api_key_info) }.to raise_exception
  end

  it "account endpoints should raise when missing key_id" do
    @api.key_id = nil
    expect { @api.account(:api_key_info) }.to raise_exception
  end

  it "character endpoints should raise when missing key_id" do
    @api.key_id = nil
    expect { @api.character(:api_key_info) }.to raise_exception
  end

  it "character endpoints should raise when missing vcode" do
    @api.vcode = nil
    expect { @api.character(:api_key_info) }.to raise_exception
  end

  it "character endpoints should raise when missing character_id" do
    @api.character_id = nil
    expect { @api.character(:api_key_info) }.to raise_exception
  end

  it "corporation endpoints should raise when missing key_id" do
    @api.key_id = nil
    expect { @api.corporation(:api_key_info) }.to raise_exception
  end

  it "corporation endpoints should raise when missing vcode" do
    @api.vcode = nil
    expect { @api.corporation(:api_key_info) }.to raise_exception
  end

  it "corporation endpoints should raise when missing character_id" do
    @api.character_id = nil
    expect { @api.corporation(:api_key_info) }.to raise_exception
  end

  it "module namespace should have VERSION" do
    expect(EveBadger::VERSION).to_not be_nil
  end
end

