require 'spec_helper'

describe EveTooper do
  before(:each) do
    @key = EveTooper::APIKey.new(keyid: 2641361, vcode: 'H7MGidb2MB7MzqPvqOOz7RtdjEyY4dHTP8u8Ojf7ywUOQ7MC8RQFRvSDQuFaX02R')
  end

  it "should initialize APIKey objects properly" do
    expect(@key.keyid).to eq('2641361')
    expect(@key.vcode).to eq('H7MGidb2MB7MzqPvqOOz7RtdjEyY4dHTP8u8Ojf7ywUOQ7MC8RQFRvSDQuFaX02R')
  end

  it "should get api key info" do
    xml = @key.account_api_key_info
    expect(xml[:key_info][:type]).to eq("FOO")
  end

  it "should get characters list" do
    xml = @key.account_characters
    xml[:rowset].each do |row|
      expect(row[:name]).to_not be_nil
    end
  end
end

