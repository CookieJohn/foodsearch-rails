require 'net/http'

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

    messageData = {
      recipient: {
        id: recipientID
      },
      message: {
        text: message
      }
    };

    token = Settings.facebook.page_access_token
    uri = URI("https://graph.facebook.com/v2.9/me/messages?access_token=#{token}")
    res = Net::HTTP.post_form(uri, messageData)
  end

  def text_format return_msg
    {
      type: 'text',
      text: return_msg
    }
  end
end