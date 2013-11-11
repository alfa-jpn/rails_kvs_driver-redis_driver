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

### sorted set
``` ruby
RailsKvsDriver::RedisDriver::Driver::session(driver_config) do |redis|
  
  # set member to redis.
  redis.sorted_sets['animations'] = ['nyarukosan',   10]
  redis.sorted_sets['animations'] = ['nonnonbiyori',  5]
  redis.sorted_sets['animations'] = ['kiniromosaic',  1]
  
  # increment score of member.
  redis.sorted_sets.increment('animations', 'nyarukosan',  1) # => increment nyarukosan score 10 -> 11
  redis.sorted_sets.increment('animations', 'nyarukosan', -1) # => increment nyarukosan score 11 -> 10
  
  # execute the block of code for each member of sorted set.
  redis.sorted_sets.each_member('animations', true) do |member, score, position|
    puts "#{position+1}:#{member} is #{score}pt." # => '1:nyarukosan is 10pt.'
                                                  # => '2:nonnonbiyori is 5pt.'
                                                  # => '3:kiniromosaic is 1pt.'
  end
  
  # get all keys
  redis.sorted_sets.keys? # => ['animations']
  
  # execute the block of code for each keys.
  redis.sorted_sets.each do |key|
    puts key # => animations
  end
 
  # get array of sorted set.
  redis.sorted_sets['animation'] # => Array[[member,score],....]
 
  # get score of member.
  redis.sorted_sets['animations', 'nyarukosan'] # => 10 
 
  # count member of sorted set.
  redis.sorted_sets.count('animations') # => 3
  
  # remove member of sorted set.
  redis.sorted_sets.remove('animations', 'nonnonbiyori')
  
  # check existed sorted set
  redis.sorted_sets.has_key?('animations') # => false
  
  # length sorted set
  redis.sorted_set.length # => 0
 
end
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
