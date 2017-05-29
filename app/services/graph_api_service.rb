require 'koala'

class GraphApiService
	# API_URL ||= "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
	TOKEN ||= 'EAACEdEose0cBAPYgHolb7ZB0LaQA1wu3CZCPi0cM8XW8r9c945RfyFrRk6DBcZB2WpoEHm2kFnEgvRUxwZCaYy4tpaTBm3z2cb7rBNIPqMlPpCeFtxJqNnwQ4fq67r0INaYrfZALGQFKwfRYrZCiiZAqiba5B4a9EAtmqlJN0XyXGZBq0eUZCkF0Xfjoo0ZBb8z6kZD'

	attr_accessor :graph
	def initialize
		graph = Koala::Facebook::API.new(TOKEN)
	end

	def place_search lat, lng
		location = "#{lat},#{lng}"
		graph = Koala::Facebook::API.new(TOKEN)
		results = graph.search('restaurant', type: :place,center: location, distance: 500)
		results = results.first(5)
		target_result = results.last
		lsat_result = graph.search(target_result['name'], type: :page)
		result = graph.get_connections(lsat_result['id'], "?fields=location,name,category,overall_star_rating,rating_count,photos")
		return result
	end

	def test lat, lng
		# location = "#{lat},#{lng}"
		# uri = URI("#{API_URL}location=#{location}&radius=#{RADIUS}&type=#{RESTAURANT_TYPE}&opennow=#{OPENNOW}&key=#{API_KEY}")
		# res = uri.get
		graph = Koala::Facebook::API.new(TOKEN)
		profile = graph.get_object("me")

		return profile
	end
end