require 'telegram/bot'

class TelegramBotService < BaseService
  TOKEN ||= Settings.telegram.token
  API_URL ||= "https://api.telegram.org/bot#{TOKEN}/"

  def initialize request
    self.user ||= nil
    self.request ||= request
  end

  def reply_msg
    true
  end
end