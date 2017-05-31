class BaseController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]

  before_action :verify_from_line, only: [:callback]

  def index
  end

  def callback
		msg = LineBotService.new.reply_msg(request)
		render plain: msg
	end

  private
    def verify_from_line
      body = request.body.read
      signature = request.env['HTTP_X_LINE_SIGNATURE']
      render status: 400 unless client.validate_signature(body, signature)
    end
end
