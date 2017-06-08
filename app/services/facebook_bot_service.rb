class FacebookBotService


	def initialize
    self.client ||= Line::Bot::Client.new { |config|
      config.channel_secret = Settings.line.channel_secret
      config.channel_token = Settings.line.channel_token
    }
    self.graph  ||= GraphApiService.new
    self.google ||= GoogleMapService.new
    self.common ||= CommonService.new
  end

  def reply_msg request
    body = request.body
  	return JSON.parse(request.body)
  end

  def text_format return_msg
    {
      type: 'text',
      text: return_msg
    }
  end
end