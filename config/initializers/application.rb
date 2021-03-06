# frozen_string_literal: true

def safe_url(link)
  URI.parse(URI.encode(link))
end

def fuzzy_match(compare_a, compare_b)
  @jarow.getDistance(compare_a, compare_b).to_f
end

def http_get(get_uri, _params = nil)
  uri = safe_url(get_uri)
  res = Net::HTTP.get_response(uri)
  JSON.parse(res.body)['results']
end

def http_post(post_uri, params)
  HTTParty.post(post_uri, body: params.to_json, headers: { 'Content-Type' => 'application/json' })
end

def count_distance(current_lat_lng, position_lat_lng)
  (Geocoder::Calculations.distance_between(current_lat_lng, position_lat_lng) * 1000).round(3)
end

# redis
def redis_key_exist?(key)
  $redis.exists(key.to_s)
end

def redis_initialize_user(user_id)
  $redis.set(user_id.to_s, {}.to_json)
end

def redis_get_user_data(user_id)
  user_data = $redis.get(user_id.to_s)
  user_data.present? ? JSON.parse(user_data) : {}
end

def redis_set_user_data(user_id, type, data)
  user_data = redis_get_user_data(user_id.to_s)
  user_data = user_data.merge(type => data)
  $redis.set(user_id.to_s, user_data.to_json)
end

def get_redis_data(user_id, keyword)
  record = redis_get_user_data(user_id)
  record.dig(keyword) || ''
end

def clear_keyword
  redis_set_user_data(@user_id, 'keyword', '')
end

def disable_customize
  redis_set_user_data(@user_id, 'customize', false)
end

def record_lat_lng(lat = nil, lng = nil)
  redis_set_user_data(@user_id, 'lat', lat)
  redis_set_user_data(@user_id, 'lng', lng)
end
