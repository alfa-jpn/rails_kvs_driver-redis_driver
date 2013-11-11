require "rails_kvs_driver/redis_driver/version"
require "rails_kvs_driver"
require "redis"

module RailsKvsDriver::RedisDriver
  class Driver < RailsKvsDriver::Base
    # connect with driver config.
    # @param driver_config [Hash]   driver config.
    # @return [Object] instance of key-value store.
    def self.connect(driver_config)
      Redis.new(host: driver_config[:host], port: driver_config[:port])
    end

    # get value from kvs.
    # @param key [String] key.
    # @return [String] value. when doesn't exist, nil.
    def [](key)
      @kvs_instance.get(safe_key(key))
    end

    # set value to kvs.
    # @param key    [String] key.
    # @param value  [String] value.
    # @return [Boolean] result
    def []=(key, value)
      @kvs_instance.set(safe_key(key), value)
    end

    # delete key from kvs.
    # @return [Boolean] result.
    def delete(key)
      (@kvs_instance.del(safe_key(key)) == 1)
    end

    # delete all keys from kvs.
    # @return [Boolean] result.
    def delete_all
      keys    = @kvs_instance.keys(safe_key('*'))
      del_num = @kvs_instance.del(keys) if keys.length > 0

      (del_num == keys.length)
    end

    # get all keys from kvs.
    # @return [Array<String>] array of key names.(only having string value)
    def keys
      keys_with_type('string')
    end

    # add sorted set to kvs.
    # when the key doesn't exist, it's made newly.
    # @note same as sorted set of redis. refer to redis.
    #
    # @param key    [String]  key of sorted set.
    # @param member [String]  member of sorted set.
    # @param score  [Float]   score of sorted set.
    # @return [Boolean] result.
    def add_sorted_set(key, member, score)
      @kvs_instance.zadd(safe_key(key), score, member)
    end

    # count members of sorted set
    # @note same as sorted set of redis. refer to redis.
    #
    # @param key [String]  key of sorted set.
    # @return [Integer] members num
    def count_sorted_set_member(key)
      @kvs_instance.zcard(safe_key(key))
    end

    # get array of sorted set.
    # @note same as sorted set of redis. refer to redis.
    #
    # @param key      [String]  key of sorted set.
    # @param start    [Integer] start index
    # @param stop     [Integer] stop index
    # @param reverse  [Boolean] order by desc
    # @return [Array<String, Float>>] array of the member and score. when doesn't exist, nil.
    def get_sorted_set(key, start=0, stop=-1, reverse=false)
      if reverse
        result = @kvs_instance.zrevrange(safe_key(key), start, stop, with_scores: true)
      else
        result = @kvs_instance.zrange(safe_key(key), start, stop, with_scores: true)
      end

      return (result.length == 0) ? nil : result
    end

    # get all sorted_set keys.
    # @return [Array<String>] array of key names.(only having sorted_set)
    def get_sorted_set_keys
      keys_with_type('zset')
    end

    # get the score of member.
    # @note same as sorted set of redis. refer to redis.
    #
    # @param key    [String]  key of sorted set.
    # @param member [String]  member of sorted set.
    # @return [Float] score of member.
    def get_sorted_set_score(key, member)
      @kvs_instance.zscore(safe_key(key), member)
    end

    # increment score of member from sorted set.
    # @note same as sorted set of redis. refer to redis.
    #
    # @param key    [String]  key of sorted set.
    # @param member [String]  member of sorted set.
    # @param score  [Float]   increment score.
    # @return [Float] value after increment
    def increment_sorted_set(key, member, score)
      @kvs_instance.zincrby(safe_key(key), score, member)
    end

    # remove sorted set from kvs.
    # This function doesn't delete a key.
    # @note same as sorted set of redis. refer to redis.
    #
    # @param key    [String]  key of sorted set.
    # @param member [String]  member of sorted set.
    # @return [Boolean] result.
    def remove_sorted_set(key, member)
      @kvs_instance.zrem(safe_key(key), member)
    end

    private
    # get safe key name with @driver_config[:namespace]
    # @param key [String] key
    # @return [String] safe key name
    def safe_key(key)
      "#{@driver_config[:namespace]}::#{key}"
    end

    # get keys with type.
    #
    # @param  [String] type of key.
    # @return [Array<String>] array of keys.
    def keys_with_type(type)
      result      = Array.new
      pattern     = safe_key('*')
      header_len  = pattern.length - 1

      @kvs_instance.keys(pattern).each do |key|
        result.push key[header_len .. -1] if @kvs_instance.type(key) == type
      end

      return result
    end
  end
end
