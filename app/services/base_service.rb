require 'fuzzystringmatch'
require 'httparty'

class BaseService

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
end