require 'spec_helper'
require 'eve_badger/endpoints'

describe EveBadger::Endpoints do
  describe "endpoint retrieval" do
    it "retrieves account endpoints" do
      EveBadger::Endpoints.account(:account_status).must_be_instance_of EveBadger::Endpoint
    end

    it "retrieves character endpoints" do
      EveBadger::Endpoints.character(:character_sheet).must_be_instance_of EveBadger::Endpoint
    end

    it "retrieves corporation endpoints" do
      EveBadger::Endpoints.corporation(:corporation_sheet).must_be_instance_of EveBadger::Endpoint
    end

    it "retrieves detail endpoints" do
      EveBadger::Endpoints.detail(:char_contract).must_be_instance_of EveBadger::Endpoint
    end

    it "raises an exception for unsupported inputs" do
      proc {EveBadger::Endpoints.account(:foo)}.must_raise RuntimeError
    end
  end

  describe EveBadger::Endpoint do
    it "gets path" do
      EveBadger::Endpoints.account(:account_status).path.must_equal "Account/AccountStatus"
    end

    it "gets access_mask" do
      EveBadger::Endpoints.account(:account_status).access_mask.must_equal 33554432
    end

    it "gets detail_id for detail endpoints" do
      EveBadger::Endpoints.detail(:wallet_journal).detail_id.must_equal "accountKey"
    end

    it "permits authorized bitmasks" do
      EveBadger::Endpoints.account(:account_status).permitted?(33554432).must_equal true
    end

    it "denies unauthorized bitmasks" do
      EveBadger::Endpoints.account(:account_status).permitted?(0).must_equal false
    end

    it "permits any mask for unsecured endpoints" do
      EveBadger::Endpoints.account(:api_key_info).permitted?(0).must_equal true
    end
  end
end
