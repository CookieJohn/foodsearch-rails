require 'koala'

class GraphApiService
	# API_URL ||= "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
	TOKEN ||= 'EAACEdEose0cBAKdSUEUUwvuTJ58rqoVOMq4pnj37wwNCS3yWFtzLXF2gu5KKXyKpEon619UoUcYTZA9JamAPJAcRttqXlZArUt6RFb0Sf3ryaCZBaVDAzhhZAJqoxR7ZCGQjZAclgd7aPq6zQNfFBY7ZBP6A1aekG2Dt7Td0IvhZB3wutdigUEZAC2kt6MSZC8PSIZD'

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

	def search_restaurant restaurant_name
		graph = Koala::Facebook::API.new(TOKEN)
		results = graph.search(restaurant_name, type: :page)
		target_result = results.first

		result = graph.get_connections(target_result['id'], "?fields=location,name,category,overall_star_rating,rating_count,photos")
		return result
	end
	def get_photo id
		graph = Koala::Facebook::API.new(TOKEN)
		result = graph.get_connections(id, "?fields=location,name,category,overall_star_rating,rating_count,photos")
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