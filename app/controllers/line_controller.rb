# frozen_string_literal: true

class LineController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]

  def callback
    msg = LineBotService.new(request).reply_msg
    render plain: msg
  end
end
