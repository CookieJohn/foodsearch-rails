# require 'net/http'

class GoogleMapService
	# API_URL ||= "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
	# API_KEY ||= Settings.google.google_api_key

	# RADIUS ||= 500
	# RESTAURANT_TYPE ||= 'restaurant'
	# OPENNOW ||= true
	# PROMINENCE ||= 'prominence'

	# def place_search lat, lng
	# 	location = "#{lat},#{lng}"
	# 	uri = URI("#{API_URL}location=#{location}&radius=#{RADIUS}&type=#{RESTAURANT_TYPE}&opennow=#{OPENNOW}&key=#{API_KEY}")
	# 	res = Net::HTTP.get_response(uri)
	# 	puts res
	# 	results = JSON.parse(res.body)['results'].first(5)

	# 	return results
	# end
	def get_map_link lat, lng
		zoom = 15
		"https://www.google.com/maps/place/#{lat},#{lng}/@#{lat},#{lng},#{zoom}z/data=!3m1!4b1"
	end

	def get_google_search query
		"https://www.google.com.tw/search?q=#{query}"
	end
end