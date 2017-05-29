require 'faraday'

class GoogleMapService
	API_URL ||= "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
	PHOTO_API_URL ||= "https://maps.googleapis.com/maps/api/place/photo?"
	API_KEY ||= ENV['GOOGLE_API_KEY']
	FIXIE_SOCKS_HOST ||= ENV['FIXIE_SOCKS_HOST']

	RADIUS ||= 1000
	RESTAURANT_TYPE ||= 'restaurant'
	OPENNOW ||= true
	PROMINENCE ||= 'prominence'

	def place_search lat, lng
		location = "#{lat},#{lng}"
		uri = URI("#{API_URL}location=#{location}&radius=#{RADIUS}&type=#{RESTAURANT_TYPE}&opennow=#{OPENNOW}&key=#{API_KEY}")

		uri = Faraday.new(url: uri, proxy: FIXIE_SOCKS_HOST)
		res = uri.get

		results = JSON.parse(res.body)['results'].first(5)

		return results
	end

	def photo size, photoreference

		uri = URI("#{PHOTO_API_URL}maxheight=#{size}&photoreference=#{photoreference}&key=#{API_KEY}")
		uri = Faraday.new(url: uri, proxy: FIXIE_SOCKS_HOST)
		res = uri.get
		puts res.body
		return JSON.parse(res.body)
	end

	def test lat, lng
		location = "#{lat},#{lng}"
		uri = URI("#{API_URL}location=#{location}&radius=#{RADIUS}&type=#{RESTAURANT_TYPE}&opennow=#{OPENNOW}&key=#{API_KEY}")

		uri = Faraday.new(url: uri, proxy: FIXIE_SOCKS_HOST)
		res = uri.get

		return res.body
	end
end