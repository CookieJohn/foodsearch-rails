require 'koala'

class GraphApiService
	# API_URL ||= "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
	TOKEN ||= 'EAACEdEose0cBAJUo9MEk8A3RDFXa6828eFsxHHzMYbpj3jH8m6DyWV5CzJHyNArTKK8IZBZBM4bclHuV2rElEwmiDHmxikZAVZC04vCYHZBujWVKQl896mTY1GFlyR8e2l9Qmso3wtjm9lwW5DLKYzfdgaC2s9chKgDexZBAUP2AV3RsfYjF5yB66FCB7Uyv0ZD'

	attr_accessor :graph
	def initialize
		graph = Koala::Facebook::API.new(TOKEN)
	end

	# def place_search lat, lng
	# 	location = "#{lat},#{lng}"
	# 	graph = Koala::Facebook::API.new(TOKEN)
	# 	results = graph.search('restaurant', type: :place,center: location, distance: 500)
	# 	results = results.first(5)
	# 	target_result = results.last
	# 	lsat_result = graph.search(target_result['name'], type: :page)
	# 	result = graph.get_connections(lsat_result['id'], "?fields=location,name,category,overall_star_rating,rating_count,photos")
	# 	return result
	# end

	def search_restaurant restaurant_name
		graph = Koala::Facebook::API.new(TOKEN)
		results = graph.search(restaurant_name, type: :page)
		target_result = results.first

		return target_result
	end
	def get_location id
		graph = Koala::Facebook::API.new(TOKEN)
		result = graph.get_connections(id, "?fields=location,name,category,overall_star_rating,rating_count,picture")
		return result
	end

	def photo id
		graph = Koala::Facebook::API.new(TOKEN)
		result = graph.get_picture_data(id, type: :large)#['data']['url']
		url = result.present? ? result['data']['url'] : ""
		return url
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