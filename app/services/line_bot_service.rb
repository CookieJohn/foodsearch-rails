class LineBotService < BaseService
  include LineFormat
  include Conversion

  attr_accessor :graph, :google, :user, :request
  def initialize request
    self.graph  ||= GraphApiService.new
    self.google ||= GoogleMapService.new
    self.user ||= nil
    self.request ||= request
  end

  def reply_msg
    varify_signature

    body = request.body.read
    return_msg = ''
    events = $line_client.parse_events_from(body)
    events.each { |event|
      find_line_user(event['source']['userId'])

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          msg = event.message['text'].downcase
          $line_client.reply_message(event['replyToken'], text_format(msg))
        when Line::Bot::Event::MessageType::Location
          lat = event.message['latitude']
          lng = event.message['longitude']
          facebook_results = graph.search_places(lat, lng, user: user)
          if facebook_results.size > 0
            options = carousel_options(facebook_results)
            return_response = carousel_format(options)
          else
            return_response = text_format(I18n.t('empty.no_restaurants'))
          end
          $line_client.reply_message(event['replyToken'], return_response)
        end
      end
    }
    return return_msg
  end

  def varify_signature
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    return '400 Bad Request' unless $line_client.validate_signature(body, signature)
  end

  def find_line_user id
    User.create!(line_user_id: id) if !User.exists?(line_user_id: id)
    self.user = User.find_by(line_user_id: id)
  end
end