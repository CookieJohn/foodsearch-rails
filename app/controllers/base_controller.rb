class BaseController < ApplicationController
	include MetaHelper

  skip_before_action :verify_authenticity_token, only: [:callback, :facebook_callback]

  def index
  	set_meta
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
