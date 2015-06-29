require 'spec_helper'
require 'eve_badger/cache'

describe EveBadger::Cache do
  it "can be enabled with a supported Moneta adapter" do
    EveBadger::Cache.enable!(:Memory)
    EveBadger::Cache.enabled?.must_equal true
  end

  it "merges {expires: true} for non expiring adapters" do
    EveBadger::Cache.enable!(:Memory)
    EveBadger::Cache.type.must_equal Moneta::Expires
  end

  it "can't be enabled with an unsupported Moneta adapter" do
    proc { EveBadger::Cache.enable!(:Unsupported) }.must_raise NameError
  end

  it "can't be enabled with junk inputs" do
    proc { EveBadger::Cache.enable!("foo") }.must_raise ArgumentError
  end
end
