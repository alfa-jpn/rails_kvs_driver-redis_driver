# RailsKvsDriver::RedisDriver

Redis Driver for [Rails_Kvs_Driver](https://github.com/alfa-jpn/rails-kvs-driver).

## Installation

Add this line to your application's Gemfile:

    gem 'rails_kvs_driver-redis_driver'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails_kvs_driver-redis_driver

## Usage(function of [Rails_Kvs_Driver](https://github.com/alfa-jpn/rails-kvs-driver).)

### define driver configuration
``` ruby
driver_config = {
  :host        => 'localhost', # host of redis
  :port        => 6379,        # port of redis
  :namespace   => 'Example',   # namespace of key
  :timeout_sec => 5,           # timeout seconds
  :pool_size   => 5,           # connection pool size
  :config_key  => :none        # This key is option. (default=:none)
                               #   when set this key.
                               #   will refer to a connection-pool based on config_key,
                               #   even if driver setting is the same without this key.
}
```

### connect and exec basic (set/get/delete)
session method enables connection pool.
You can use [Enumerable](http://docs.ruby-lang.org/ja/1.9.3/class/Enumerable.html).

``` ruby

RailsKvsDriver::RedisDriver::Driver::session(driver_config) do |redis|
  
  # set key to redis.
  redis['animation']   = 'good!'
  redis['nyarukosan']  = 'kawaii!'
  
  # get value from redis.
  puts redis['animation']   # => 'good!'
  
  # exec each
  redis.each do |key,value|
    puts "#{key} is #{value}!" # => animation is good!!
                               # => nyarukosan is kawaii!!
  end
  
  # check existed.
  redis.has_key?('animation') # => true
  
  # get all keys.
  redis.keys    # => ['animation', 'nyarukosan']
  
  # delete key from redis.
  redis.delete('nyarukosan')
  
  # delete all keys.
  redis.delete_all
  
end
```

detail [DefinedBaseMethod](http://rubydoc.info/github/alfa-jpn/rails-kvs-driver/RailsKvsDriver/DefinedBaseMethod)

### list
lists include [Enumerable](http://docs.ruby-lang.org/ja/1.9.3/class/Enumerable.html).

``` ruby

RailsKvsDriver::RedisDriver::Driver::session(driver_config) do |redis|

  # set value to list.
  redis.lists['anime'][0]   = 'nyarukosan'
  redis.lists['anime'][1]   = 'kinnmoza'
  redis.lists['anime'][2]   = 'outbreakcompany'

  # or can use this.
  redis.lists['fruit'] = [:apple, :orange]


  # get value of list.
  puts redis.lists['anime'][0] # => 'nyarukosan'


  # execute the block of code for each keys.
  redis.lists.each do {|key| puts key }  # => anime fruit

  # execute the block of code for each member of list.
  redis.lists['anime'].each do |index, value|
    puts "#{index}: #{value}." # => '0: nyarukosan.'
                               # => '1: kinnmoza.'
                               # => '2: outbreakcompany.'
  end

  # get all keys
  redis.lists.keys? # => ['anime', 'fruit']

  # length of sorted set.
  redis.lists.length # => 2

  # length member of sorted set.
  redis.lists['anime'].length # => 3


  # delete key
  redis.lists.delete('fruit')

  # remove member of list.
  redis.lists['anime'].delete('kinnmoza')

  # or can use this.
  redis.lists['anime'].delete_at(1)

end
```

detail [Lists](http://rubydoc.info/github/alfa-jpn/rails-kvs-driver/RailsKvsDriver/Lists/Lists)
and [List](http://rubydoc.info/github/alfa-jpn/rails-kvs-driver/RailsKvsDriver/Lists/List)


### sorted set
sorted_sets include [Enumerable](http://docs.ruby-lang.org/ja/1.9.3/class/Enumerable.html).

``` ruby

RailsKvsDriver::RedisDriver::Driver::session(driver_config) do |redis|
  
  # set member to redis.
  redis.sorted_sets['anime']['nyarukosan']   = 10
  redis.sorted_sets['anime']['nonnonbiyori'] =  5
  redis.sorted_sets['anime']['kiniromosaic'] =  1

  # or can use this.
  redis.sorted_set['fruit'] = [['apple', 1], ['orange', 2]]


  # get score of member.
  redis.sorted_sets['anime']['nyarukosan'] # => 10


  # increment score of member.
  redis.sorted_sets['anime'].increment('nyarukosan',  1) # => increment nyarukosan score 10 -> 11
  redis.sorted_sets['anime'].increment('nyarukosan', -1) # => increment nyarukosan score 11 -> 10


  # execute the block of code for each keys.
  redis.sorted_sets.each do {|key| puts key }  # => anime fruit

  # execute the block of code for each member of sorted set.
  redis.sorted_sets['anime'].each(true) do |member, score, position|
    puts "#{position+1}:#{member} is #{score}pt." # => '1:nyarukosan is 10pt.'
                                                  # => '2:nonnonbiyori is 5pt.'
                                                  # => '3:kiniromosaic is 1pt.'
  end


  # get all keys
  redis.sorted_sets.keys? # => ['anime', 'fruit']

  # get all members
  redis.sorted_sets['anime'].members? # => nyarukosan nonnonbiyori kiniromosaic


  # length of sorted set.
  redis.sorted_sets.length # => 2

  # length member of sorted set.
  redis.sorted_sets['anime'].length # => 3



  # delete key
  redis.sorted_sets.delete('fruit')

  # remove member of sorted set.
  redis.sorted_sets['anime'].remove('nonnonbiyori')


  # check if key exist.
  redis.sorted_sets.has_key?('fruit') # => false

  # check if member exist.
  redis.sorted_sets['anime'].has_member?('nyarukosan') # => true

 
end
```

detail [SortedSets](http://rubydoc.info/github/alfa-jpn/rails-kvs-driver/RailsKvsDriver/SortedSets/SortedSets)
and [SortedSet](http://rubydoc.info/github/alfa-jpn/rails-kvs-driver/RailsKvsDriver/SortedSets/SortedSet)

# API DOCUMENT

* [RailsKvsDriver-RedisDriver](http://rubydoc.info/github/alfa-jpn/rails_kvs_driver-redis_driver/master/frames)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
