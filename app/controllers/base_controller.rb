class BaseController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback, :facebook_callback]

  def index
  end

  def callback
		msg = LineBotService.new.reply_msg(request)
		render plain: msg
	end

	def facebook_callback
		render plain: '200'
	end
end
