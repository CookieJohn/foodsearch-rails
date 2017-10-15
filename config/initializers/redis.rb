require "redis"

def connect_to_redis
  $redis = Redis.new(url: ENV['redis_url'], timeout: 15)
end

connect_to_redis
