require 'load_path'

LoadPath.configure do
  add sibling_directory 'lib'
end

require 'minitest/spec'
require 'minitest/autorun'
require 'eve_badger'

# Enable cache to speed up tests and reduce http spam
EveBadger::Cache.enable :Memory
