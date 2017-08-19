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
    msg = body.dig('message','text')
    self.chat_id = body.dig('message','from','id')
    lat = body.dig('message','location','latitude')
    lng = body.dig('message','location','longitude')

    if chat_id.present?
      response_api = "#{API_URL}sendMessage"
      if lat.present?
        response = text_format(lat)
      elsif msg.present?
        response = key_board_button_format(msg)
      end
      results = http_post(response_api, response)
    end
  end

  def text_format text
    { chat_id: chat_id, 
      text: text }
  end

  def key_board_button_format text
    { chat_id: chat_id, 
      text: text,
      parse_mode: 'Markdown',
      reply_markup: {
        keyboard: [
          [text: '請給我位置', request_location: true]],
        resize_keyboard: true,
        one_time_keyboard: true }}
  end
end