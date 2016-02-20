$LOAD_PATH.unshift( File.expand_path '../lib' )

require 'minitest/spec'
require 'minitest/autorun'
require 'eve_badger'

# Enable cache to speed up tests and reduce http spam
EveBadger::Cache.enable :Memory
