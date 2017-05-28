require 'koala'

class GraphApiService
	# API_URL ||= "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"

	attr_accessor :graph
	def initialize
		graph = Koala::Facebook::API.new
	end

	# def place_search lat, lng
	# 	location = "#{lat},#{lng}"
	# 	uri = URI("#{API_URL}location=#{location}&radius=#{RADIUS}&type=#{RESTAURANT_TYPE}&opennow=#{OPENNOW}&key=#{API_KEY}")

	# 	uri = Faraday.new(url: uri, proxy: FIXIE_URL)
	# 	res = uri.get

	# 	results = JSON.parse(res.body)['results'].first(5)

	# 	return results
	# end

	def test lat, lng
		# location = "#{lat},#{lng}"
		# uri = URI("#{API_URL}location=#{location}&radius=#{RADIUS}&type=#{RESTAURANT_TYPE}&opennow=#{OPENNOW}&key=#{API_KEY}")

		# uri = Faraday.new(url: uri, proxy: FIXIE_URL)
		# res = uri.get
		@graph = Koala::Facebook::API.new('EAACEdEose0cBAK7irL9VZBWkhHzHkQ5fVi9C9ImvHjcxHSOUF9dOGQZA3Umdywc1dWZCE0w7iomdYerPjY58NtvUmUGLoxEYvkufU88Wms2UMtkuKJU2ZAWOa7kDolN5TzKL9pl0GEMHlaRN58lg7jz6PHXOm6pm3o6fWD8iGnCJEKFX6gISvh4jJsPsGggZD')
		profile = @graph.get_object("me")

		return profile
	end
end