class BaseController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback, :facebook_callback]

  def index
  	render plain: '200'
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
		render plain: msg
	end
end
