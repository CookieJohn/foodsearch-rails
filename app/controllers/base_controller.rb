class BaseController < ApplicationController
  def index
  end

  def callback
		msg = LineBotService.new.reply_msg(request)
		render text: msg
	end
end
