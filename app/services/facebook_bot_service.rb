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

    entries = body['entry']

    senderID = entries.first['messaging'].first['sender']['id']
    message = entries.first['messaging'].first.dig('message','text').present? ? entries.first['messaging'].first['message']['text'] : 'QQ'

    # entries.each do |entry|
    #   entry['messaging'].each do |message|
    #     message   = message['message']['text'].to_s
    #     senderID = message['sender']['id']
    #   end
    # end

    messageData = self.text_format(senderID, message)

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