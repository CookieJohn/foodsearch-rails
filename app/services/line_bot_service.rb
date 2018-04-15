# frozen_string_literal: true

require 'line/bot'

class LineBotService < BaseService
  include LineFormat
  include Conversion

  def initialize(request)
    @line_client ||= Line::Bot::Client.new.tap do |config|
      config.channel_secret = ENV['line_channel_secret']
      config.channel_token  = ENV['line_channel_token']
    end
    @graph   ||= GraphApiService.new
    @google  ||= GoogleMapService.new
    @request ||= request
    @user    ||= nil
  end

  def reply_msg
    varify_signature

    body = @request.body.read
    events = @line_client.parse_events_from(body)
    events.each do |event|
      # find_line_user(event['source']['userId'])

      case event
      when Line::Bot::Event::Message
        reply = case event.type
                when Line::Bot::Event::MessageType::Text
                  # msg = event.message['text'].downcase
                  # text_format(msg)
                when Line::Bot::Event::MessageType::Location
                  lat = event.message['latitude']
                  lng = event.message['longitude']
                  facebook_results = @graph.search_places(lat, lng, user: @user)

                  return text_format(I18n.t('empty.restaurants')) if facebook_results.empty?

                  options = carousel_options(facebook_results)
                  carousel_format(options)
                end

        @line_client.reply_message(event['replyToken'], reply)
      end
    end
  end

  def varify_signature
    body = @request.body.read
    sign = @request.env['HTTP_X_LINE_SIGNATURE']
    return '400 Bad Request' unless @line_client.validate_signature(body, sign)
  end

  def find_line_user(id)
    User.create!(line_user_id: id) unless User.exists?(line_user_id: id)
    @user = User.find_by(line_user_id: id)
  end
end
