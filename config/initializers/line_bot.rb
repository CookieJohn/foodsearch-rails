require 'line/bot'

$line_client ||= Line::Bot::Client.new { |config|
  config.channel_secret = ENV['line_channel_secret']
  config.channel_token = ENV['line_channel_token']
}