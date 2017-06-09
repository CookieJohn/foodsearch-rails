# require 'net/http'
require 'httparty'

class FacebookBotService

	def initialize
    # self.graph  ||= GraphApiService.new
    # self.google ||= GoogleMapService.new
    # self.common ||= CommonService.new
  end

  def reply_msg request
    body = request.body.read

    entries = body['entry']
    page = body['object']

    # senderID = entries.first['messaging'].first['sender']['id']
    # message = entries.first['messaging'].first['message']['text']
    # Rails.logger.info "entries: #{entries}"
    if page == 'page'
      entries.each do |entry|
        entry['messaging'].each do |message|
          message = message['message']['text'].to_s
          senderID = message['sender']['id']
          # Rails.logger.info "message: #{message}"
          # Rails.logger.info "senderID: #{senderID}"
          if message.present?
            messageData = self.text_format(senderID, message)
            token = Settings.facebook.page_access_token
            uri = "https://graph.facebook.com/v2.6/me/messages?access_token=#{token}"
            # res = Net::HTTP.post_form(uri, messageData)
            res = HTTParty.post(uri, body: messageData)
            # Rails.logger.info "res: #{JSON.parse(res)}"
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