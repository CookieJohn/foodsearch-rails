class FacebookController < ApplicationController
	skip_before_action :verify_authenticity_token, only: [:post_webhook]

	def webhook
		render plain: params['hub.challenge'], status: 200
	end

	def post_webhook
		msg = FacebookBotService.new.reply_msg(request)
		render plain: msg
	end
end
