require "redis"

def connect_to_redis
  $redis = Redis.new(url: Settings.redis.url)
end

connect_to_redis
