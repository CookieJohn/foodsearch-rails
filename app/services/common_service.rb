require 'fuzzystringmatch'
require 'net/http'
require 'httparty'

class CommonService

	attr_accessor :jarow
	def initialize
    self.jarow ||= FuzzyStringMatch::JaroWinkler.create(:native)
  end

	def safe_url link
		uri = URI.encode(link)
    uri = URI.parse(uri)
	end

	def fuzzy_match compare_a, compare_b
		jarow.getDistance(compare_a,compare_b).to_f
	end

	def http_get get_uri, params=nil
		uri = safe_url(get_uri)
		res = Net::HTTP.get_response(uri)
		results = JSON.parse(res.body)['results']
	end

	def http_post post_uri, params
		uri = safe_url(post_uri)
		res = HTTParty.post(uri, body: params.to_json, headers: { 'Content-Type' => 'application/json' })
		results = JSON.parse(res.body)
	end
end