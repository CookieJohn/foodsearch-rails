require "redis"

def connect_to_redis
  $redis = Redis.new(url: Settings.redis.url, timeout: 15)
end

connect_to_redis
