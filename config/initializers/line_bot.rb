require 'line/bot'

$line_client ||= Line::Bot::Client.new { |config|
  config.channel_secret = Settings.line.channel_secret
  config.channel_token = Settings.line.channel_token
}