class GoogleMapService < BaseService
	API_KEY ||= Settings.google.google_api_key
	API_URL ||= 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=#{API_KEY}&'

	RADIUS ||= 500
	RESTAURANT_TYPE ||= 'restaurant'

  def initialize
    @hydra ||= Typhoeus::Hydra.new
  end

	def search_places lat, lng, user=nil, keywords=nil
		max_distance = user.present? ? user.max_distance : RADIUS
		results = []
		requests = keywords.map {|keyword|
			uri = safe_url("#{API_URL}location=#{lat},#{lng}&radius=#{max_distance}&type=#{RESTAURANT_TYPE}&keyword=#{keyword}")
			request = Typhoeus::Request.new(uri, followlocation: true, ssl_verifypeer: false)
			@hydra.queue(request)
			request
		}
		@hydra.run
		responses = requests.map { |request|
			result = JSON.parse(request.response.body)['results']
		  results += result if result.present?
		}
		return results
	end

	def search_place_by_keyword lat, lng, user=nil, keyword=nil
		max_distance = user.present? ? user.max_distance : RADIUS
		results = http_get("#{API_URL}location=#{lat},#{lng}&radius=#{max_distance}&type=#{RESTAURANT_TYPE}&keyword=#{keyword}")
	end

	def get_map_link lat, lng, name, street
		"https://www.google.com/maps/place/#{lat},#{lng}/@#{lat},#{lng},14z/data=!3m1!4b1"
	end

	def get_nevigation saddr, daddr
		"http://maps.google.com/maps?saddr=#{saddr}&daddr=#{daddr}"
	end

	def get_google_search query
		"https://www.google.com/search?q=#{query}"
	end
end