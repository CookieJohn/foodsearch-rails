require 'net/http'
# require 'httparty'

class FacebookBotService

	def initialize
    # self.graph  ||= GraphApiService.new
    # self.google ||= GoogleMapService.new
    # self.common ||= CommonService.new
  end

  def reply_msg request
    body = JSON.parse(request.body.read)
    entries = body['entry']

    if body.dig('object') == 'page'
      entries.each do |entry|
        entry['messaging'].each do |message|
          reveive_message = message['message']['text'].to_s
          senderID = message['sender']['id']
          Rails.logger.info "reveive_message: #{reveive_message}"
          Rails.logger.info "senderID: #{senderID}"
          if reveive_message.present?
            messageData = self.text_format(senderID, reveive_message)
            token = Settings.facebook.page_access_token
            uri = "https://graph.facebook.com/v2.6/me/messages?access_token=#{token}"
            res = Net::HTTP.post_form(uri, messageData)
            # res = HTTParty.post(uri, body: messageData)
          end
        end
      end
    end
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