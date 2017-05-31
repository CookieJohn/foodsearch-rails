require 'koala'

class GraphApiService
	DEFAULT_DISTANCE ||= 500
	DEFAULT_MIN_SCORE ||= 3.9
	DEFAULT_FIELDS ||= 'location,name,overall_star_rating,rating_count,phone,link,price_range,category_list'
	DEFAULT_LOCALE ||= 'zh-TW'
	DEFAULT_RANDOM ||= true

	REJECT_PRICE ||= ['$$$','$$$$']

	attr_accessor :graph
	def initialize
		@oauth = Koala::Facebook::OAuth.new
		oauth_access_token = @oauth.get_app_access_token
		self.graph = Koala::Facebook::API.new(oauth_access_token)
	end

	def search_places lat, lng, user=nil
			
		max_distance = user.present? ? user.max_distance : DEFAULT_DISTANCE
		min_score = user.present? ? user.min_score : DEFAULT_MIN_SCORE
		random_type = user.present? ? user.random_type : DEFAULT_RANDOM

		location = "#{lat},#{lng}"
		facebook_results = graph.search('restaurant', type: :place,center: location, distance: max_distance, fields: DEFAULT_FIELDS, locale: DEFAULT_LOCALE)
		results = facebook_results.reject { |r| REJECT_PRICE.include?(r['price_range'].to_s) }
		results = results.select { |r| r['overall_star_rating'].to_f >= min_score }
		results = results.sort_by { |r| r['overall_star_rating'].to_f }.reverse

		if random_type
			results = results.sample(5)
		else
			results = results.first(5)
		end
		return results
	end

	def get_photo id
		"https://graph.facebook.com/#{id}/picture?type=large"
	end

end