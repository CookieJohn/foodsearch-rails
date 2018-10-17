# frozen_string_literal: true

require 'redis'

def connect_to_redis
  $redis = Redis.new(url: ENV['REDIS_URL'], timeout: 15)
end

connect_to_redis
