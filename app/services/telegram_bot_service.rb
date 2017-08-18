class TelegramBotService < BaseService
  TOKEN ||= Settings.telegram.token
  API_URL ||= "https://api.telegram.org/bot#{TOKEN}/"

  attr_accessor :request
  def initialize request
    # self.user ||= nil
    self.request ||= request
  end

  def reply_msg
    body = JSON.parse(request.raw_post)
    msg = body['message']['text']
    chat_id = body['message']['from']['id']

    if msg.present?
      response_api = "#{API_URL}sendMessage"
      messageData = {chat_id: chat_id, text: msg}

      results = http_post(response_api, messageData)
    end
  end
end