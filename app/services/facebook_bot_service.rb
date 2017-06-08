require 'net/http'

class FacebookBotService

	def initialize
    # self.graph  ||= GraphApiService.new
    # self.google ||= GoogleMapService.new
    # self.common ||= CommonService.new
  end

  def reply_msg request
    body = request.body
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

    # qs = { access_token: PAGE_ACCESS_TOKEN },
    uri = URI('https://graph.facebook.com/v2.9/me/messages')
    # res = Net::HTTP.post_form(uri, 'q' => ['ruby', 'perl'], 'max' => '50')
  	return JSON.parse(request.body)
  end

  def text_format return_msg
    {
      type: 'text',
      text: return_msg
    }
  end
end