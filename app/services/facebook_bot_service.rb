class FacebookBotService

	def initialize
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