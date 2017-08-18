class TelegramBotService < BaseService
  TOKEN ||= Settings.telegram.token
  API_URL ||= "https://api.telegram.org/bot#{TOKEN}/"

  attr_accessor :request
  def initialize request
    # self.user ||= nil
    self.request ||= request
  end

  def reply_msg
    body = request.body.read
    msg = body.dig('message','text')
    true
  end
end