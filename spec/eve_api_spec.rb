require 'spec_helper'
require 'eve_badger/eve_api'

describe EveBadger::EveAPI do
  let(:keyID) { '2641361' }
  let(:vcode) { 'H7MGidb2MB7MzqPvqOOz7RtdjEyY4dHTP8u8Ojf7ywUOQ7MC8RQFRvSDQuFaX02R' }
  let(:characterID) { '93772629' }
  let(:accessMask) { '26091848' }
  let(:keyType) { 'Character' }
  let(:params) { {key_id: keyID, vcode: vcode, character_id: characterID, access_mask: accessMask, key_type: keyType} }
  let(:new_key) { EveBadger::EveAPI.new }
  let(:valid_key) { EveBadger::EveAPI.new(params) }

  describe "#new" do
    it "won't have key_id" do
      new_key.key_id.must_equal nil
    end

    it "won't' have vcode" do
      new_key.vcode.must_equal nil
    end

    it "won't have character_id" do
      new_key.character_id.must_equal nil
    end
  end

  describe "general behavior" do
    it "automatically retrieves key_type" do
      key = new_key
      key.key_id = keyID
      key.vcode = vcode
      key.account(:api_key_info)
      key.key_type.must_be_instance_of Symbol
    end

    it "automatically retrieves access_mask" do
      key = new_key
      key.key_id = keyID
      key.vcode = vcode
      key.account(:api_key_info)
      key.access_mask.must_be_instance_of Fixnum
    end
  end

  describe "#account" do
    it "gets a response with valid attributes" do
      key = new_key
      key.key_id = keyID
      key.vcode = vcode
      key.account(:api_key_info).must_be_instance_of EveBadger::Response
    end

    it "raises for insufficient access_mask" do
      key = new_key
      key.key_id = keyID
      key.vcode = vcode
      key.access_mask = 0
      key.key_type = keyType
      proc { key.account(:account_status) }.must_raise EveBadger::APIKeyError
    end

    it "raises for missing key_id" do
      key = new_key
      key.key_id = nil
      key.vcode = vcode
      proc { key.account(:api_key_info) }.must_raise EveBadger::APIKeyError
    end

    it "raises for missing vcode" do
      key = new_key
      key.key_id = keyID
      key.vcode = nil
      proc { key.account(:api_key_info) }.must_raise EveBadger::APIKeyError
    end

    it "raises for missing key and vcode" do
      key = new_key
      key.key_id = nil
      key.vcode = nil
      proc { key.account(:api_key_info) }.must_raise EveBadger::APIKeyError
    end
  end

  describe "#character" do

    it "gets a response with valid attributes" do
      key = new_key
      key.key_id = keyID
      key.vcode = vcode
      key.character_id = characterID
      key.character(:character_sheet).must_be_instance_of EveBadger::Response
    end

    it "raises for missing key_id" do
      key = new_key
      key.key_id = nil
      key.vcode = vcode
      proc { key.character(:character_sheet) }.must_raise EveBadger::APIKeyError
    end

    it "raises for missing vcode" do
      key = new_key
      key.key_id = keyID
      key.vcode = nil
      proc { key.character(:character_sheet) }.must_raise EveBadger::APIKeyError
    end

    it "raises for missing character_id" do
      key = new_key
      key.key_id = keyID
      key.vcode = vcode
      key.character_id = nil
      proc { key.character(:character_sheet) }.must_raise EveBadger::APIKeyError
    end

    it "raises for missing key, vcode and character_id" do
      key = new_key
      key.key_id = nil
      key.vcode = nil
      key.character_id = nil
      proc { key.character(:character_sheet) }.must_raise EveBadger::APIKeyError
    end
  end

  # TODO: create throwaway corp to test against
  describe "#corporation" do
    it "raises for wrong key_type" do
      key = new_key
      key.key_id = keyID
      key.vcode = vcode
      key.key_type = :Character
      key.character_id = characterID
      proc { key.corporation(:corporation_sheet) }.must_raise EveBadger::APIKeyError
    end

    it "raises for missing character_id" do
      key = new_key
      key.key_id = keyID
      key.vcode = vcode
      key.key_type = :Corporation
      key.character_id = nil
      proc { key.corporation(:corporation_sheet) }.must_raise EveBadger::APIKeyError
    end
  end

  # TODO: test this too
  describe "#details" do
  end
end
