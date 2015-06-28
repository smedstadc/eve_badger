require 'spec_helper'
require 'eve_badger/cache'

describe EveBadger::Cache do
  let(:moneta_handler) { Moneta.new(:Memory, expires: true) }
  let(:bad_handler) { "foo handler" }

  it "can be enabled with a Moneta object" do
    EveBadger::Cache.enable!(moneta_handler)
    EveBadger::Cache.enabled?.must_equal true
  end

  it "can't be enabled without a Moneta object" do
    proc { EveBadger::Cache.enable!(bad_handler) }.must_raise ArgumentError
  end
end
