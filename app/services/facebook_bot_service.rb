# require 'net/http'
require 'httparty'

class FacebookBotService

	def initialize
    # self.graph  ||= GraphApiService.new
    # self.google ||= GoogleMapService.new
    # self.common ||= CommonService.new
  end

  def reply_msg request
    body = JSON.parse(request.body.read)
    senderID = body['entry'].first['messaging'].first['sender']['id']
    recipientID = body['entry'].first['messaging'].first['recipient']['id']
    timeOfMessage = body['entry'].first['time']
    message = body['entry'].first['messaging'].first['message']['text']

    messageData = self.text_format(recipientID, message)

    token = Settings.facebook.page_access_token
    uri = "https://graph.facebook.com/v2.6/me/messages?access_token=#{token}"
    # res = Net::HTTP.post_form(uri, messageData)
    res = HTTParty.post(uri, body: messageData)
    Rails.logger.info res
  end

  def text_format id, text
    {
      recipient: {
        id: id
      },
      message: {
        text: text
      }
    }
  end
end