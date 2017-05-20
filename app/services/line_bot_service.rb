require 'active_support'
require 'line/bot'

class LineBotService

  attr_accessor :client
  def initialize
    self.client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['CHANNEL_SECRET']
      config.channel_token = ENV['CHANNEL_TOKEN']
    }
  end

  def reply_msg request
    body = request.body.read

    bot = LineBotService.new
    bot.varify_signature(request)

    return_msg = ''
    events = client.parse_events_from(body)
    events.each { |event|
      if bot.msg_varify!
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            msg = event.message['text'].to_s.downcase
            # 回覆
            client.reply_message(event['replyToken'], bot.text_format(msg))
          when Line::Bot::Event::MessageType::Location
            msg = event.message['address'].to_s.downcase
            address_msg = GoogleMapService.new.place_search
            # 回覆
            client.reply_message(event['replyToken'], bot.text_format(address_msg))
          when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
            response = client.get_message_content(event.message['id'])
            tf = Tempfile.open("content")
            tf.write(response.body)
          end
        end
      else
        break
      end
    }
    return return_msg
  end

  def text_format return_msg
    {
      type: 'text',
      text: return_msg+'!'
    }
  end

  def image_format return_msg=nil
    {
      type: 'sticker',
      packageId: 1,
      stickerId: 13,
    }
  end

  def carousel_format return_msg=nil
    {
      type: "template",
      altText: "this is a carousel template",
      template: {
        type: "carousel",
        columns: [
          {
            thumbnailImageUrl: "",
            title: "",
            text: "",
            actions: [
              {
                type: "uri",
                label: "",
                uri: ""
              },
            ]
          }
        ]
      }
    }
  end

  def button_format
    {
      type: "template",
      altText: "this is a confirm template",
      template: {
        type: "confirm",
        text: "",
        actions: [
          {
            type: "message",
            label: "",
            text: ""
          },
          {
            type: "message",
            label: "",
            text: ""
          }
        ]
      }
    }
  end

  def msg_varify! msg=nil
    true
  end

  def varify_signature request
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      # error 400 do 'Bad Request' end
      return_msg = '400 Bad Request'
      return '400 Bad Request'
    end
  end

end