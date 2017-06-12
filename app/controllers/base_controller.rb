class BaseController < ApplicationController
	include MetaHelper

  skip_before_action :verify_authenticity_token, only: [:callback, :facebook_callback]

  def index
  	set_meta
  end

  def refresh_locations
  	lat = params['lat']
  	lng = params['lng']
  	fb_results = GraphApiService.new.search_places(lat, lng, nil, 999)
  	keywords = fb_results.map {|f| f['name']}
    google_results = GoogleMapService.new.search_places(lat, lng, nil, keywords)

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
end
