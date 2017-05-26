class BaseController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]

  def index
  	@test = GoogleMapService.new.place_search(25.084555, 121.456564)
  end

  def callback
		msg = LineBotService.new.reply_msg(request)
		render plain: msg
	end
end
