require 'spec_helper'

describe "EveBadger" do
  before(:all) do
    # This key has all public information enabled as well as the private endpoints for
    # character info, character sheet, skill training and current skill in training.
    # You can expect the tests won't break if you replace these values with any single
    # character or account key with the same permissions.
    @test_key_id = '2641361'
    @test_vcode = 'H7MGidb2MB7MzqPvqOOz7RtdjEyY4dHTP8u8Ojf7ywUOQ7MC8RQFRvSDQuFaX02R'
    @test_char_id = '93772629'
    @test_mask = '26091848'
    @test_key_type = 'Character'
  end

  describe "Module" do
    it "should get version" do
      expect(EveBadger.version).to eq('0.2.0')
    end
    it "should get user agent" do
      expect(EveBadger.user_agent).to_not be_nil
    end
    it "should get tq domain" do
      expect(EveBadger.tq_domain).to eq('https://api.eveonline.com/')
    end
    it "should get sisi domain" do
      expect(EveBadger.sisi_domain).to eq('https://api.testeveonline.com/')
    end
  end

  describe "EveAPI Object Creation" do
    it "should make new EveAPI objects" do
      @api = EveBadger::EveAPI.new
      expect(@api.key_id).to be_nil
      expect(@api.vcode).to be_nil
      expect(@api.character_id).to be_nil
    end

    it "should initialize attributes" do
      @api = EveBadger::EveAPI.new(key_id: @test_key_id, vcode: @test_vcode,
                                   character_id: @test_char_id, access_mask: @test_mask, key_type: @test_key_type)
      expect(@api.key_id).to eq @test_key_id
      expect(@api.vcode).to eq @test_vcode
      expect(@api.character_id).to eq @test_char_id
      expect(@api.access_mask).to eq @test_mask.to_i
      expect(@api.key_type).to eq @test_key_type.to_sym
      @api = EveBadger::EveAPI.new(key_id: @test_key_id.to_i, vcode: @test_vcode,
                                   character_id: @test_char_id.to_i, access_mask: @test_mask.to_i,
                                   key_type: @test_key_type.to_sym)
      expect(@api.key_id).to eq @test_key_id
      expect(@api.vcode).to eq @test_vcode
      expect(@api.character_id).to eq @test_char_id
      expect(@api.access_mask).to eq @test_mask.to_i
      expect(@api.key_type).to eq @test_key_type.to_sym
    end

    it "should set and get attributes" do
      @api = EveBadger::EveAPI.new
      @api.key_id = @test_key_id
      expect(@api.key_id).to eq @test_key_id
      @api.key_id = @test_key_id.to_i
      expect(@api.key_id).to eq @test_key_id
      @api.vcode = @test_vcode
      expect(@api.vcode).to eq @test_vcode
      @api.character_id = @test_char_id
      expect(@api.character_id).to eq @test_char_id
      @api.character_id = @test_char_id.to_i
      expect(@api.character_id).to eq @test_char_id
      @api.access_mask = @test_mask
      expect(@api.access_mask).to eq @test_mask.to_i
      @api.access_mask = @test_mask.to_i
      expect(@api.access_mask).to eq @test_mask.to_i
    end
  end

  describe "EveAPI Cache Settings" do
    it "should default to some kind of cache" do
      expect(EveBadger::EveAPI.request_cache).to_not be_nil
    end
    it "should let user disable cache" do
      expect(EveBadger::EveAPI.request_cache).to_not be_nil
      EveBadger::EveAPI.disable_request_cache
      expect(EveBadger::EveAPI.request_cache).to be_nil
    end
    it "should let user enable cache" do
      EveBadger::EveAPI.enable_request_cache
      expect(EveBadger::EveAPI.request_cache).to_not be_nil
    end
  end

  describe "EveAPI Request Logic" do
    before(:each) do
      @api = EveBadger::EveAPI.new(key_id: @test_key_id, vcode: @test_vcode,
                                   character_id: @test_char_id, access_mask: @test_mask)
      @info_endpoint = {path: "Account/APIKeyInfo", access_mask: 0}
      @status_endpoint = {path: "Account/AccountStatus", access_mask: 33554432}
    end

    it "should send api_request with an endpoint hash" do
      allow(@api).to receive(:endpoint_permitted?)
      allow(@api).to receive(:get_response)
      expect(@api).to receive(:api_request).with(@info_endpoint)
      @api.account(:api_key_info)
    end

    it "should fetch the key's access mask if it is needed, but not provied" do
      @api.access_mask = nil
      expect(@api).to receive(:get_access_mask)
      allow(@api).to receive(:get_response)
      @api.account(:account_status)
    end

    it "should check that the endpoint is permitted by the access mask" do
      allow(@api).to receive(:endpoint_permitted?).and_return(true)
      expect(@api).to receive(:endpoint_permitted?).with(@info_endpoint)
      allow(@api).to receive(:get_response)
      @api.account(:api_key_info)
    end

    it "should raise an exception when the endpoint is not permitted" do
      allow(@api).to receive(:endpoint_permitted?).and_return(false)
      expect { @api.account(:account_status) }.to raise_exception
    end

    it "should build uri and get an api response when the endpoint is permitted" do
      allow(@api).to receive(:endpoint_permitted?).and_return(true)
      allow(@api).to receive(:get_response)
      allow(@api).to receive(:build_uri).and_return('url')
      expect(@api).to receive(:build_uri)
      expect(@api).to receive(:get_response).with('url')
      @api.account(:account_status)
    end

    it "should send params when building a uri for a request" do
      allow(@api).to receive(:endpoint_permitted?).and_return(true)
      allow(@api).to receive(:get_response)
      expect(@api).to receive(:params)
      allow(@api).to receive(:get_response)
      @api.account(:account_status)
    end

    it "should build params without any character_id set" do
      @api.character_id = nil
      expect(@api.send(:params)).to_not be_nil
    end

    it "should get response from cache if possible" do
      allow(@api).to receive(:endpoint_permitted?).and_return(true)
      allow(@api).to receive(:build_uri).and_return('url')
      allow(@api).to receive(:cache_get).with('url').and_return('foo')
      expect(@api).to receive(:cache_get).with('url')
      expect(@api).to receive(:badgerfish_from).with('foo')
      @api.account(:account_status)
    end

    it "should get response from http when not cached" do
      allow(@api).to receive(:endpoint_permitted?).and_return(true)
      allow(@api).to receive(:build_uri).and_return('url')
      allow(@api).to receive(:cache_get).with('url').and_return(false)
      allow(@api).to receive(:http_get).with('url').and_return('foo')
      expect(@api).to receive(:http_get).with('url')
      expect(@api).to receive(:badgerfish_from).with('foo')
      @api.account(:account_status)
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
  end

  describe "EveAPI Account Endpoint Usage" do
    before(:each) do
      @api = EveBadger::EveAPI.new(key_id: @test_key_id, vcode: @test_vcode,
                                   character_id: @test_char_id, access_mask: @test_mask)
    end

    it "should get api key info" do
      response = @api.account(:api_key_info)
      expect(response['key']).to_not be_nil
    end

    it "should get list of characters" do
      response = @api.account(:list_of_characters)
      expect(response['rowset']['row']).to_not be_nil
    end
  end

  describe "EveAPI Character Endpoint Usage" do
    before(:each) do
      @api = EveBadger::EveAPI.new(key_id: @test_key_id, vcode: @test_vcode,
                                   character_id: @test_char_id, access_mask: @test_mask)
    end

    it "should get skill in training" do
      response = @api.character(:skill_in_training)
      expect(response['skillInTraining']['$']).to_not be_nil
    end

    it "should get character sheet" do
      response = @api.character(:character_sheet)
      expect(response['characterID']['$']).to eq(@test_char_id)
    end
  end

  describe "EveAPI Corporation Endpoint Usage" do
    before(:each) do
      @api = EveBadger::EveAPI.new(key_id: @test_key_id, vcode: @test_vcode,
                                   character_id: @test_char_id, access_mask: @test_mask)
      @corpsheet_endpoint = {path: "Corp/CorporationSheet", access_mask: 0}
    end
    it "should raise exception when not a corporation key" do
      expect {@api.corporation(:corporation_sheet)}.to raise_exception
    end
  end

  describe "EveAPI Detail Endpoint Usage" do
    pending "TODO: Write These Tests"
  end
end
