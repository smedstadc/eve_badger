require 'test_helper'

describe EveBadger::Throttle do
  before do
    EveBadger::Throttle.disable
  end

  it "should be disabled by default" do
    EveBadger::Throttle.enabled?.must_equal false
  end

  it "should enable default rate limits" do
    EveBadger::Throttle.enable_default
    EveBadger::Throttle.enabled?.must_equal true
  end

  it "should enable custom rate limits" do
    EveBadger::Throttle.enable_custom(100)
    EveBadger::Throttle.enabled?.must_equal true
  end

  it "should disable rate limits" do
    EveBadger::Throttle.enable_default
    EveBadger::Throttle.disable
    EveBadger::Throttle.enabled?.must_equal false
  end
end