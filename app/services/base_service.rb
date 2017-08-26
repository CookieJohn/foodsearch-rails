require 'fuzzystringmatch'
require 'httparty'

class BaseService
	REJECT_CATEGORY ||= I18n.t('settings.facebook.reject_category')

	@jarow ||= FuzzyStringMatch::JaroWinkler.create(:native)

	def safe_url link
		uri = URI.encode(link)
    uri = URI.parse(uri)
	end

	def fuzzy_match compare_a, compare_b
		@jarow.getDistance(compare_a,compare_b).to_f
	end

	def http_get get_uri, params=nil
		uri = safe_url(get_uri)
		res = Net::HTTP.get_response(uri)
		results = JSON.parse(res.body)['results']
	end

	def http_post post_uri, params
		res = HTTParty.post(post_uri, body: params.to_json, headers: { 'Content-Type' => 'application/json' })
	end

	def count_distance current_lat_lng, position_lat_lng
		Geocoder::Calculations.distance_between(current_lat_lng, position_lat_lng).round(3)
	end

	# redis
	def redis_key_exist?(key)
		$redis.exists(key.to_s)
	end

	def redis_initialize_user(user_id)
		$redis.set(user_id.to_s, "{}".to_json)
	end

	def redis_get_user_data(user_id)
		JSON.parse($redis.get(user_id.to_s))
	end

	def redis_set_user_data(user_id, type, data)
		user_data = redis_get_user_data(user_id)
		user_data = user_data.merge(type => data)
		$redis.set(user_id.to_s, user_data.to_json)
	end

	def get_redis_data(user_id, keyword)
		record = redis_get_user_data(user_id)
		data = record.dig(keyword) || ""
	end
end