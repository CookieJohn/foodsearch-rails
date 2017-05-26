require 'net/http'
require 'google_maps_service'

class GoogleMapService
	API_URL ||= "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
	API_KEY ||= ENV['GOOGLE_API_KEY']

	RADIUS ||= 500
	RESTAURANT_TYPE ||= 'restaurant'

	attr_accessor :gmaps
  def initialize
    gmaps ||= GoogleMapsService::Client.new(key: API_KEY)
  end

	def place_search lat, lng
		location = "#{lat},#{lng}"
		uri = URI("#{API_URL}location=#{location}&radius=#{RADIUS}&type=#{RESTAURANT_TYPE}&key=#{API_KEY}")
		res = Net::HTTP.get(uri)
		return res
	end
end