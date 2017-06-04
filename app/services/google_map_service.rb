require 'net/http'

class GoogleMapService
	API_URL ||= "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
	API_KEY ||= Settings.google.google_api_key

	RADIUS ||= 500
	RESTAURANT_TYPE ||= 'restaurant'
	# OPENNOW ||= true
	# PROMINENCE ||= 'prominence'

	attr_accessor :common, :hydra
  def initialize
    self.common ||= CommonService.new
    self.hydra ||= Typhoeus::Hydra.new
  end

	def search_places lat, lng, user=nil, keywords=nil
		max_distance = user.present? ? user.max_distance : RADIUS
		results = []
		requests = keywords.map {|keyword|
			uri = common.safe_url("#{API_URL}location=#{lat},#{lng}&radius=#{max_distance}&type=#{RESTAURANT_TYPE}&keyword=#{keyword}&key=#{API_KEY}")
			request = Typhoeus::Request.new(uri, followlocation: true)
			hydra.queue(request)
			request
		}
		hydra.run
		requests.each do |request|
			Rails.logger.info "request: #{request}"
		  Rails.logger.info "body: #{request.response.body}"
		  results += JSON.parse(request.response.body)['results']
		end
		return results
	end

	def search_place_by_keyword lat, lng, user=nil, keyword=nil
		max_distance = user.present? ? user.max_distance : RADIUS
		uri = common.safe_url("#{API_URL}location=#{lat},#{lng}&radius=#{max_distance}&type=#{RESTAURANT_TYPE}&keyword=#{keyword}&key=#{API_KEY}")
		res = Net::HTTP.get_response(uri)
		results = JSON.parse(res.body)['results']
		return results
	end

	def get_map_link lat, lng, name, street
		zoom = I18n.t('settings.google.zoom')
		# "https://www.google.com/maps/place/#{lat},#{lng}/@#{lat},#{lng},#{zoom}z/data=!3m1!4b1"
		query = name.strip
		query += ",#{street.strip}" if street.present?
		"https://www.google.com/maps?q=#{query}&z=#{zoom}"
	end

	def get_google_search query
		"https://www.google.com/search?q=#{query}"
	end
end