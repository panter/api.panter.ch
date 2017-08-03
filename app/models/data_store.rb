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

    def clear
      redis.del(redis.keys('dashboard:*'))
    end

    def redis
      @redis ||= Redis.new
    end
  end
end
