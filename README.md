# EveBadger

It badgers the Eve: Online API for [badgerfish](http://badgerfish.ning.com/) responses. Get it?

## About

EveBadger is a lightweight interface to the Eve: Online API. Build an EveAPI object to represent your API key and call out to the endpoint you're interested in. It'll return a JSON/Hash representing the response. It also handles caching, throttling and access masks out of the box.

I wrote this for 3 reasons:

* I prefer working with JSON over XML
* I wasn't in love with existing EveAPI solutions
* I wanted to learn how to build a custom Gem (Ruby packaging is awesome, btw)
 
## What does it do?

* Obeys CCP's default request rate limit (can be disabled if you have an exception)
* Caches responses until their respective cachedUntil timestamps (can be disabled if you prefer your own method)
* Respects access masks for keys and endpoints (it will raise an exception if you try to access an endpoint that isn't allowed by the keys access mask)
* Probably annoys OO purists

## What doesn't it do?

* EveBadger won't wrap each response inside a nice endpoint specific object, it just gives you the JSON.
* Doesn't cover the entire EveAPI (just Account, Character and Corporation endpoints this will improve in time)
* It doesn't install from rubygems yet, because I haven't published it (but you can add a git entry to your Gemfile if you want to use it before I do)

## Planned Improvements

* **Full API Coverage** Right now EveBadger covers the stuff I use the most. Eventually I'll go through and add all the remaining endpoints.
* **Cache Configuration** EveBadger uses the Moneta gem for caching. Currently it's pretty dumb and only tries to link up with an unprotected redis instance on localhost, if this fails it'll fall back to an in-memory Moneta store. I'd like to allow users to configure most aspects of the Moneta store.
* **Rowset Extraction** *(Maybe)* I'm happy with JSON responses for the most part. I don't want or need a full object for every endpoint, but a single basic response object which does a nice job of extracting rowsets and delegating indexes might be nice.
* **RubyGems** Once I polish a few things and settle on a handful of decisions I'll publish this to rubygems.

## Usage Examples

The basic idea is to make an EveAPI object and call the appropriate category method with the symbol representing the name of the endpoint. It'll spit back JSON and you take it from there.

I think you'll find that the category methods and endpoint names map directly to the EveAPI documentation at [this location](https://neweden-dev.com/API). 

### Getting a Character List
```ruby
api = EveBadger::EveAPI.new(key_id: my_key_id, vcode: my_vcode)
response = api.account(:list_of_characters)
response['rowset']['row'].each do |row|
  puts row['@name']
end
```

### Getting Key Info
```ruby
api = EveBadger::EveAPI.new(key_id: my_key_id, vcode: my_vcode)
response = api.account(:api_key_info)
puts response['key']['@accessMask']
puts response['key']['@type']
```

### Getting a Tower List
```ruby
# corporation endpoints expect you to also pass the character_id for the character on the key
api = EveBadger::EveAPI.new(key_id: my_key_id, vcode: my_vcode, character_id: my_character_id)
response = api.corporation(:starbase_list)
response['rowset']['row'].each |starbase|
  puts starbase['@state']
end
```

### Getting the Details of a Specific Object
```ruby
api = EveBadger::EveAPI.new(key_id: my_key_id, vcode: my_vcode, character_id: my_character_id)
# Detail endpoints are the only exception to the category/endpoint pattern
# Any endpoint that pulls the details of a particular thing is accessed via the details method
# Simply pass the extra argument for id_of_interest
response = api.details(:starbase_detail, my_id_of_interest)  
response['rowset']['row'].each |fuel_row|
  puts "#{fuel_row['@typeID']} - #{fuel_row['@quantity']}"
end
```

### Creating an Object for a Test Server API
```ruby
api = EveBadger::EveAPI.new(server: :sisi, key_id: my_key_id, vcode: my_vcode, character_id: my_character_id)
# then ontinue as normal
```

### Tips for Edge Cases

Most of the time you can get away with `response['rowset']['row'].each` but sometimes there is just one row in the rowset and in that case `.each` will iterate over the elements of the object. This is something I'd like to handle automatically inside a generic wrapper for responses in the future. In the meantime it's a good idea to use `.is_a?(Hash)` as a guard clause to handle the single-row case when working with rowsets.
