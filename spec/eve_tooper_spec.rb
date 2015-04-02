require 'spec_helper'

describe EveTooper do
  before(:all) do
    @eve = EveTooper::EveApi(server: :tq)
    @key = EveTooper::AccountKey.new(keyid: 2641361, vcode: 'H7MGidb2MB7MzqPvqOOz7RtdjEyY4dHTP8u8Ojf7ywUOQ7MC8RQFRvSDQuFaX02R')
  end

  it "should make APIKey objects with keyid and vcode" do
    expect(@key.keyid).to eq('2641361')
    expect(@key.vcode).to eq('H7MGidb2MB7MzqPvqOOz7RtdjEyY4dHTP8u8Ojf7ywUOQ7MC8RQFRvSDQuFaX02R')
  end

  it "should make AccountAPIKey objects with"

  it "should get api key info" do
    response = @key.account_api_key_info
    expect(response['key']['@type']).to eq('Account')
  end

  it "should get characters list" do
    response = @key.account_characters
    response['rowset']['row'].each do |row|
      expect(row['@name']).to_not be_nil
    end
  end

  it "should load endpoints data json" do
    acct_info = EveTooper.account_endpoint(:api_key_info)
    char_info = EveTooper.character_endpoint(:account_balance)
    expect(acct_info[:path]).to_not be_nil
    expect(char_info[:path]).to_not be_nil
  end
end

