require 'net/http'

class GoogleMapService
	API_URL ||= "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
	PHOTO_API_URL ||= "https://maps.googleapis.com/maps/api/place/photo?"
	API_KEY ||= ENV['GOOGLE_API_KEY']

	RADIUS ||= 1000
	RESTAURANT_TYPE ||= 'restaurant'
	OPENNOW ||= true
	PROMINENCE ||= 'prominence'

	def place_search lat, lng
		location = "#{lat},#{lng}"
		uri = URI("#{API_URL}location=#{location}&radius=#{RADIUS}&type=#{RESTAURANT_TYPE}&opennow=#{OPENNOW}&key=#{API_KEY}")
		res = Net::HTTP.get(uri)

		results = JSON.parse(res.body)['results'].first(5)

		return results
	end

	def test lat, lng
		location = "#{lat},#{lng}"
		uri = URI("#{API_URL}location=#{location}&radius=#{RADIUS}&type=#{RESTAURANT_TYPE}&opennow=#{OPENNOW}&key=#{API_KEY}")
		res = Net::HTTP.get(uri)

		return JSON.parse(res.body)
	end
end