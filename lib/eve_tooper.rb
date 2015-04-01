require 'slowweb'

module EveTooper
  VERSION = '0.0.1'
  SlowWeb.limit('api.eveonline.com', 29, 60)


  def self.foo
    "foo"
  end
end