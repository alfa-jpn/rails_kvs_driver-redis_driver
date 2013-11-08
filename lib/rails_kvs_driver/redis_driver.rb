require "rails_kvs_driver/redis_driver/version"
require "rails_kvs_driver"
require "redis"

module RailsKvsDriver::RedisDriver
  class Driver < RailsKvsDriver::Base
    # connect with driver config.
    # @return [Boolean] result
    def connect
      begin
        @kvs_inst = Redis.new(host: @driver_config[:host], port: @driver_config[:port])
        return true
      rescue
        return false
      end
    end

    # get value from kvs.
    # @param key [String] key.
    # @return [String] value.
    def [](key)
      @kvs_inst.get(safe_key(key))
    end

    # set value to kvs.
    # @param key    [String] key.
    # @param value  [String] value.
    # @return [Boolean] result
    def []=(key, value)
      @kvs_inst.set(safe_key(key), value)
    end

    # get all keys from kvs.
    # @return [Array<String>] array of key names.
    def all_keys
      result      = Array.new
      pattern     = safe_key('*')
      header_len  = pattern.length - 1

      @kvs_inst.keys(pattern).each do |key|
        result.push key[header_len .. -1]
      end

      return result
    end

    # delete key from kvs.
    # @return [Boolean] result.
    def delete(key)
      (@kvs_inst.del(safe_key(key)) == 1)
    end

    # delete all keys from kvs.
    # @return [Boolean] result.
    def delete_all
      keys    = @kvs_inst.keys(safe_key('*'))
      del_num = @kvs_inst.del(keys) if keys.length > 0

      (del_num == keys.length)
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
      @kvs_inst.zadd(safe_key(key), score, member)
    end

    # remove sorted set from kvs.
    # This function doesn't delete a key.
    # @note same as sorted set of redis. refer to redis.
    #
    # @param key    [String]  key of sorted set.
    # @param member [String]  member of sorted set.
    # @return [Boolean] result.
    # @abstract remove sorted set from kvs.
    def remove_sorted_set(key, member)
      @kvs_inst.zrem(safe_key(key), member)
    end

    # increment score of member from sorted set.
    # @note same as sorted set of redis. refer to redis.
    #
    # @param key    [String]  key of sorted set.
    # @param member [String]  member of sorted set.
    # @param score  [Float]   increment score.
    # @return [Float] value after increment
    # @abstract increment score of member from sorted set.
    def increment_sorted_set(key, member, score)
      @kvs_inst.zincrby(safe_key(key), score, member)
    end

    # get the score of member.
    # @note same as sorted set of redis. refer to redis.
    #
    # @param key    [String]  key of sorted set.
    # @param member [String]  member of sorted set.
    # @return [Float] score of member.
    # @abstract get the score of member.
    def sorted_set_score(key, member)
      @kvs_inst.zscore(safe_key(key), member)
    end

    # get array of sorted set.
    # @note same as sorted set of redis. refer to redis.
    #
    # @param key      [String]  key of sorted set.
    # @param start    [Integer] start index
    # @param stop     [Integer] stop index
    # @param reverse  [Boolean] order by desc
    # @return [Array<String, Float>>] array of the member and score.
    # @abstract get array of sorted set.
    def sorted_set(key, start=0, stop=-1, reverse=false)
      if reverse
        @kvs_inst.zrevrange(safe_key(key), start, stop, with_scores: true)
      else
        @kvs_inst.zrange(safe_key(key), start, stop, with_scores: true)
      end
    end

    # count members of sorted set
    # @note same as sorted set of redis. refer to redis.
    #
    # @param key [String]  key of sorted set.
    # @return [Integer] members num
    def count_sorted_set_member(key)
      @kvs_inst.zcard(safe_key(key))
    end

    private
    # get safe key name with @driver_config[:namespace]
    # @param key [String] key
    # @return [String] safe key name
    def safe_key(key)
      "#{@driver_config[:namespace]}::#{key}"
    end
  end
end
