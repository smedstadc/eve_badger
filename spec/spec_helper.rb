require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
require 'eve_badger/cache'

reporter_options = { color: true }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

# Enable cache to speed up tests and reduce http spam
EveBadger::Cache.enable!(:Memory)
