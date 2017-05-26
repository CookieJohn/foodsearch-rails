require 'faraday'

class GoogleMapService
	API_URL ||= "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
	API_KEY ||= ENV['GOOGLE_API_KEY']
	FIXIE_URL ||= ENV['FIXIE_URL']

	RADIUS ||= 1000
	RESTAURANT_TYPE ||= 'restaurant'
	OPENNOW ||= true
	PROMINENCE ||= 'prominence'

	def place_search lat, lng
		location = "#{lat},#{lng}"
		uri = URI("#{API_URL}location=#{location}&radius=#{RADIUS}&type=#{RESTAURANT_TYPE}&opennow=#{OPENNOW}&key=#{API_KEY}")

		uri = Faraday.new(url: uri, proxy: FIXIE_URL)
		res = uri.get

		results = JSON.parse(res.body)['results'].first(5)

		return results
	end

	def test lat, lng
		location = "#{lat},#{lng}"
		uri = URI("#{API_URL}location=#{location}&radius=#{RADIUS}&type=#{RESTAURANT_TYPE}&opennow=#{OPENNOW}&key=#{API_KEY}")

		uri = Faraday.new(url: uri, proxy: FIXIE_URL)
		res = uri.get

		return res.body
	end
end