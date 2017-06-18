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
			request = Typhoeus::Request.new(uri, followlocation: true, ssl_verifypeer: false)
			hydra.queue(request)
			request
		}
		hydra.run
		responses = requests.map { |request|
			result = JSON.parse(request.response.body)['results']
		  results += result if result.present?
		}
		return results
	end

	def search_place_by_keyword lat, lng, user=nil, keyword=nil
		max_distance = user.present? ? user.max_distance : RADIUS
		results = common.http_get("#{API_URL}location=#{lat},#{lng}&radius=#{max_distance}&type=#{RESTAURANT_TYPE}&keyword=#{keyword}&key=#{API_KEY}")
	end

	def get_map_link lat, lng, name, street
		# zoom = I18n.t('settings.google.zoom')
		# "https://www.google.com/maps/place/#{lat},#{lng}/@#{lat},#{lng},#{zoom}z/data=!3m1!4b1"
		query = name.strip
		query += ",#{street.strip}" if street.present?
		"https://www.google.com/maps?q=#{query}"
	end

	def get_nevigation saddr, daddr
		"http://maps.google.com/maps?saddr=#{saddr}&daddr=#{daddr}"
	end

	def get_google_search query
		"https://www.google.com/search?q=#{query}"
	end
end