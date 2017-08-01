class FacebookController < ApplicationController
	skip_before_action :verify_authenticity_token, only: [:webhook]

	def webhook
		render plain: params['hub.challenge'], status: 200
	end

	def facebook_callback
		msg = FacebookBotService.new.reply_msg(request)
		render plain: '200'
	end
end
