class BaseController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback, :facebook_callback]
  before_action :get_lat_lng, only: [:refresh_locations]

  def index
  	set_meta
  end

  def search
  	set_meta
  end

  def refresh_locations
    mode = cookies['mode'].present? ? cookies['mode'] : 'score'
    type = cookies['type'].present? ? cookies['type'] : 'restaurant'
    type = @search_type.present? ? @search_type : type

  	fb_results = GraphApiService.new.search_places(@lat, @lng, nil, 999, mode, type)
  	keywords = fb_results.map {|f| f['name']}
    google_results = GoogleMapService.new.search_places(@lat, @lng, nil, keywords)

    @location_data = FormatService.new.web_format(fb_results, google_results)
    respond_to do |format|
	    format.js
	  end
  end

  def callback
		msg = LineBotService.new.reply_msg(request)
		render plain: msg
	end

	def webhook
		render plain: params['hub.challenge'], status: 200
	end

	def facebook_callback
		msg = FacebookBotService.new.reply_msg(request)
		render plain: '200'
	end

	def privacy
	end

  private
    def get_lat_lng
      @lat = params['lat']
      @lng = params['lng']
      @search_type = params.dig('search_type')
    end
end
