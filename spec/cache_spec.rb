require 'spec_helper'
require 'eve_badger/cache'

describe EveBadger::Cache do
  it "is enabled by default" do
    EveBadger::Cache.enabled?.must_equal true
  end

  it "stores and retrieves values" do
    EveBadger::Cache.store('test_key', 'test_value')
    EveBadger::Cache.get('test_key').must_equal 'test_value'
  end
end
