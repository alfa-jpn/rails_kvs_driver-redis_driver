require 'rubygems'
require 'bundler/setup'
require 'rails_kvs_driver/redis_driver'

RSpec.configure do |config|
  config.mock_framework = :rspec
end