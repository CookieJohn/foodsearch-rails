class BaseController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]

  def index
  end

  def callback
		msg = LineBotService.new.reply_msg(request)
		render plain: msg
	end
end
