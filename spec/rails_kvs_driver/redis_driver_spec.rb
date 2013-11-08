require 'rspec'
require 'spec_helper'
require 'common_example'

describe RailsKvsDriver::RedisDriver::Driver do

  driver_config = {
    :host           => 'localhost',           # host of KVS.
    :port           => 6379,                  # port of KVS.
    :namespace      => 'SPEC::RedisDriver',   # namespace of avoid a conflict with key
    :timeout_sec    => 5,                     # timeout seconds.
    :pool_size      => 5                      # connection pool size.
  }

  it_should_behave_like 'RailsKvsDriver example', RailsKvsDriver::RedisDriver::Driver, driver_config

end