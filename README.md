# EveBadger

It badgers the Eve: Online API for [badgerfish](http://badgerfish.ning.com/) responses. Get it? (Don't worry. You can still get plain XML if you want to.)

## About

EveBadger is a lightweight interface to the Eve: Online XML API. Build an EveAPI object to represent your API key and call out to the endpoint you're interested in. It'll return a response object that you can can easily consume as JSON or XML. EveBadger also respects access masks automatically and makes caching and throttling responses as easy as flipping a switch.

I wrote this for 3 reasons:

* I prefer working with JSON over XML
* I wasn't in love with existing EveAPI solutions
* I wanted to learn how to build a custom Gem (Ruby packaging is awesome, btw)

## What does it do?

* Can throttle the request rate so you don't hit CCP's default rate limit. (Disabled by default.)
* Uses Moneta to cache responses with whatever supported backend you prefer. (Disabled by default.)
* Automatically fetches missing access_mask and key_type values from the API Key Info endpoint.
* Respects access masks for keys and endpoints (it will raise an exception instead of making an HTTP request if you try to access an endpoint that isn't allowed by the key's access mask)
* Probably annoys OO purists a little.

## What doesn't it do?

* EveBadger won't wrap each response inside a nice endpoint specific object, it just gives you the JSON or XML and can truncate the response to the <result> section if you prefer.

## Planned Improvements

* **Full API Coverage** Right now EveBadger covers the stuff I use the most. Eventually I'll go through and add all the remaining endpoints.
* **Rowset Extraction** *(Maybe)* I'm happy with JSON responses for the most part. I don't want or need a full object for every endpoint, but a single basic response object which does a nice job of extracting rowsets and delegating indexes might be nice.

## Basic Usage

The basic idea is to make an EveAPI object and call the appropriate category method with the symbol representing the name of the endpoint. It'll spit back a response object you can take JSON or XML from and use however you want.

I think you'll find that the category methods and endpoint names map directly to the EveAPI documentation at [this location](https://neweden-dev.com/API).


### Getting Key Info as JSON
```ruby
api = EveBadger::EveAPI.new(key_id: my_key_id, vcode: my_vcode)
response = api.account(:api_key_info).as_json
```

### Getting Key Info as XML
```ruby
api = EveBadger::EveAPI.new(key_id: my_key_id, vcode: my_vcode)
response = api.account(:api_key_info).as_xml
document = MyFavoriteXMLParser.new(response)
```

## More Examples

You'll notice that these examples all use `.result_as_json` and `.result_as_xml`. Instead of `.as_json` or `.as_xml`. This isn't a typo. The response object allows you to take the whole response as JSON/XML or only the contents enclosed in `<result></result>` tags.

The full responses from `.as_*` are good if you need the timestamp data for your own uses.

The truncated responses from `.result_as_*` are nice if you don't need the extra stuff and just want to skip the `<eveapi>`  and `<result>` nodes.

### Getting a Character List
```ruby
api = EveBadger::EveAPI.new(key_id: my_key_id, vcode: my_vcode)
response = api.account(:list_of_characters).result_as_json
response['rowset']['row'].each do |row|
  puts row['@name']
end
```

### Getting a Tower List
```ruby
# Corporation endpoints expect you to also pass
# the character_id for the character on the key.
api = EveBadger::EveAPI.new
api.key_id = my_key_id
api.vcode = my_vcode
api.character_id = my_character_id
response = api.corporation(:starbase_list).result_as_json
response['rowset']['row'].each |starbase|
  puts starbase['@state']
end
```

### Getting the Details of a Specific Object
```ruby
# Detail endpoints are the only exception to the category/endpoint pattern.
# Any endpoint that pulls the details of a particular thing is accessed via
# the details method by passing an extra argument for id_of_interest.
api = EveBadger::EveAPI.new
api.key_id = my_key_id
api.vcode = my_vcode
api.character_id my_character_id
response = api.details(:starbase_detail, my_id_of_interest).result_as_json  
response['rowset']['row'].each |fuel_row|
  puts "#{fuel_row['@typeID']} - #{fuel_row['@quantity']}"
end
```

### Creating an Object for the Test Server API
```ruby
api = EveBadger::EveAPI.new(server: :sisi)
api.key_id = my_key_id
api.vcode = my_vcode
api.character_id = my_character_id
# then continue as normal
```

### Request Caching
```ruby
# EveBadger::Cache.enable takes the same arguments as Moneta.new
# See Moneta API docs for possible configurations:
# http://www.rubydoc.info/gems/moneta/frames
#
# EveBadger will automatically merge in {expires: true} if the
# chosen adapter doesn't support expiration natively.
#
# Caching is handled automatically while a cache adapter is enabled.
EveBadger::Cache.enable(:Redis)

# You can also disable an enabled cache if you want to for some reason
# just keep in mind that all your cached data will go poof if you use
# an the :Memory adapter.
EveBadger::Cache.disable
```

### Request Throttling
```ruby
# EveBadger::Thottle.enable_default will set CCPs default rate
# limit of 30 requests per minute.
EveBadger::Throttle.enable_default

# Use EveBadger::Throttle.enable_custom to set a custom limit if
# you have arranged for an exception for your app.
requests_per_minute = 100
EveBadger::Throttle.enable_custom(requests_per_minute)

# Like caching, you may disable a previously enabled throttle.
EveBadger::Throttle.disable
```

### Tips for Edge Cases

Most of the time you can get away with `response['rowset']['row'].each` but sometimes there is just one row in the rowset and in that case `.each` will iterate over the elements of the object. This is something I'd like to handle automatically inside a generic wrapper for responses in the future. In the meantime it's a good idea to use `.is_a?(Hash)` as a guard clause to handle the single-row case when working with rowsets.
