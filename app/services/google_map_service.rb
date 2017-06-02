# require 'net/http'

class GoogleMapService
	API_URL ||= "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
	API_KEY ||= Settings.google.google_api_key

	RADIUS ||= 500
	RESTAURANT_TYPE ||= 'restaurant'
	# OPENNOW ||= true
	# PROMINENCE ||= 'prominence'

	def place_search lat, lng, user=nil, keywords=nil
		max_distance = user.present? ? user.max_distance : RADIUS
		location = "#{lat},#{lng}"
		search_keywords = keywords.present? ? "&keyword=#{keywords}" : ""
		uri = URI.encode("#{API_URL}location=#{location}&radius=#{max_distance}&type=#{RESTAURANT_TYPE}#{search_keywords}&key=#{API_KEY}")
		uri = URI.parse(uri)
		res = Net::HTTP.get_response(uri)
		results = JSON.parse(res.body)['results']
		return results
	end

	def get_map_link lat, lng, name, street
		zoom = I18n.t('settings.google.zoom')
		# "https://www.google.com/maps/place/#{lat},#{lng}/@#{lat},#{lng},#{zoom}z/data=!3m1!4b1"
		"https://www.google.com/maps/place/#{name.strip},#{street.strip}/#{lat},#{lng}/@#{lat},#{lng},#{zoom}z/data=!3m1!4b1"
	end

	def get_google_search query
		"https://www.google.com/search?q=#{query}"
	end
end