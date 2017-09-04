class DataStore
  class << self
    def set(key, object)
      redis.set("dashboard:#{key}", object.to_json)
    end

    def get(key)
      value = redis.get("dashboard:#{key}")
      return unless value
      JSON.parse(value)
    end

    # if the `key` does not exist in the data store a block is yielded which
    # should return the value to be set.
    # returns the stored value otherwise.
    def get_or_set(key)
      value = get(key)
      return value if value

      value = yield
      set(key, value)
      value
    end

    def clear
      redis.del(redis.keys('dashboard:*'))
    end

    def redis
      @redis ||= Redis.new
    end
  end
end
