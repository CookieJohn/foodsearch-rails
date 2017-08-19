class TelegramBotService < BaseService
  TOKEN ||= Settings.telegram.token
  API_URL ||= "https://api.telegram.org/bot#{TOKEN}/sendMessage"

  attr_accessor :request, :chat_id, :graph, :google, :user
  def initialize request
    self.graph  ||= GraphApiService.new
    self.google ||= GoogleMapService.new
    self.user ||= nil
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
      if lat.present?
        response = text_format(lat)
        keyword = user.last_search['keyword'].present? ? user.last_search['keyword'] : nil
        fb_results = graph.search_places(lat, lng, user, 10, nil, keyword)
        if fb_results.size > 0 
          response = text_format(lat)
        else
          response = text_format('no_result')
        end
      elsif msg.present?
        response = reply_format(msg)
      end
      results = http_post(API_URL, response)
    end
  end

  def text_format text
    { chat_id: chat_id, 
      text: text }
  end

  def reply_format text
    { chat_id: chat_id, 
      text: text,
      parse_mode: 'Markdown',
      reply_markup: {
        keyboard: [ location_button_format ],
        resize_keyboard: true,
        one_time_keyboard: true }}
  end

  def location_button_format
    [ text: '請告訴我您的位置', request_location: true ]
  end
end