require 'koala'

class GraphApiService
	# API_URL ||= "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"

	DEFAULT_DISTANCE ||= 500
	DEFAULT_FIELDS ||= 'location,name,overall_star_rating,rating_count,category,phone,link'

	attr_accessor :graph
	def initialize
		@oauth = Koala::Facebook::OAuth.new
		oauth_access_token = @oauth.get_app_access_token
		self.graph = Koala::Facebook::API.new(oauth_access_token)
	end

	def search_places lat, lng
		location = "#{lat},#{lng}"
		facebook_results = graph.search('restaurant', type: :place,center: location, distance: DEFAULT_DISTANCE, fields: DEFAULT_FIELDS)
		results = facebook_results.sort_by { |r| r['overall_star_rating'].to_i }.reverse.first(5)
		# results = results.first(5)
		# target_result = results.last
		# lsat_result = graph.search(target_result['name'], type: :page)
		# result = graph.get_connections(lsat_result['id'], "?fields=location,name,category,overall_star_rating,rating_count,photos")
		return results
	end

	def search_restaurant restaurant_name
		results = graph.search(restaurant_name, type: :page)
		target_result = results.first

		return target_result
	end
	def get_location id
		result = graph.get_connections(id, "?fields=location,name,category,overall_star_rating,rating_count,picture")
		return result
	end

	def photo id
		result = graph.get_picture_data(id, type: :large)#['data']['url']
		url = result.present? ? result['data']['url'] : ""
		return url
	end

	def get_photo id
		"https://graph.facebook.com/#{id}/picture?type=large"
	end

	def test lat, lng
		# location = "#{lat},#{lng}"
		# uri = URI("#{API_URL}location=#{location}&radius=#{RADIUS}&type=#{RESTAURANT_TYPE}&opennow=#{OPENNOW}&key=#{API_KEY}")
		# res = uri.get
		profile = graph.get_object("me")

		return profile
	end
end