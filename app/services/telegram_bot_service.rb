class TelegramBotService < BaseService
  TOKEN ||= Settings.telegram.token
  API_URL ||= "https://api.telegram.org/bot#{TOKEN}/"

  attr_accessor :request, :chat_id
  def initialize request
    # self.user ||= nil
    self.request ||= request
    self.chat_id ||= chat_id
  end

  def reply_msg
    body = JSON.parse(request.raw_post)
    msg = body['message']['text']
    self.chat_id = body['message']['from']['id']

    if chat_id.present? && msg.present?
      response_api = "#{API_URL}sendMessage"
      response = text_format(msg)

      results = http_post(response_api, response)
    end
  end

  def text_format text
    { chat_id: chat_id, 
      text: text }
  end
end