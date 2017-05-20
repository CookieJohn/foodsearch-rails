require 'net/http'

class GoogleMapService
	API_URL ||= "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
	API_KEY ||= ENV['GOOGLE_API_KEY']

	RADIUS ||= 500
	RESTAURANT_TYPE ||= 'restaurant'

	def place_search 
		test_location = '-33.8670522,151.1957362'
		uri = URI("#{API_URL}location=#{test_location}&radius=#{RADIUS}&type=#{RESTAURANT_TYPE}&key=#{API_KEY}")
		res = Net::HTTP.get(uri)
		return res
	end
end