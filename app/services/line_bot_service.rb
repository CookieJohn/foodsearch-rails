require 'line/bot'

class LineBotService < BaseService
  include LineFormat
  include Conversion

  def initialize request
    @line_client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['line_channel_secret']
      config.channel_token = ENV['line_channel_token']
    }
    @graph ||= GraphApiService.new
    @google ||= GoogleMapService.new
    @request ||= request
    @user ||= nil
  end

  def reply_msg
    varify_signature

    body = @request.body.read
    events = @line_client.parse_events_from(body)
    events.each { |event|
      find_line_user(event['source']['userId'])

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          msg = event.message['text'].downcase
          @line_client.reply_message(event['replyToken'], text_format(msg))
        when Line::Bot::Event::MessageType::Location
          lat = event.message['latitude']
          lng = event.message['longitude']
          facebook_results = @graph.search_places(lat, lng, user: @user)
          if facebook_results.size > 0
            options = carousel_options(facebook_results)
            return_response = carousel_format(options)
          else
            return_response = text_format(I18n.t('empty.restaurants'))
          end
          @line_client.reply_message(event['replyToken'], return_response)
        end
      end
    }
    200
  end

  def varify_signature
    body = @request.body.read
    signature = @request.env['HTTP_X_LINE_SIGNATURE']
    return '400 Bad Request' unless @line_client.validate_signature(body, signature)
  end

  def find_line_user id
    User.create!(line_user_id: id) if !User.exists?(line_user_id: id)
    @user = User.find_by(line_user_id: id)
  end
end
