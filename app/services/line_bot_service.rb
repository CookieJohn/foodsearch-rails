require 'active_support'
require 'line/bot'

class LineBotService

  attr_accessor :client
  def initialize
    self.client ||= Line::Bot::Client.new { |config|
      config.channel_secret = Settings.line.channel_secret
      config.channel_token = Settings.line.channel_token
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
            # msg = event.message['text'].to_s.downcase

            # client.reply_message(event['replyToken'], bot.text_format(msg))
          when Line::Bot::Event::MessageType::Location
            msg = event.message['address'].to_s.downcase
            if event.message['address'].include?("台灣")
              lat = event.message['latitude'].to_s
              lng = event.message['longitude'].to_s
              # google_result = GoogleMapService.new.place_search(lat, lng)
              fb_results = GraphApiService.new.search_places(lat, lng)

              client.reply_message(event['replyToken'], bot.carousel_format(fb_results))
              # client.reply_message(event['replyToken'], bot.text_format(msg+lat+lng))
            end

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

  def carousel_format results=nil
    zoom = 15    
    test_image_url = 'https://pbs.twimg.com/media/CgzniPeUkAEMkTl.jpg'
    google_service = GoogleMapService.new
    fb_service = GraphApiService.new

    columns = []
    # results.each do |result|
    #   lat = result['geometry']['location']['lat']
    #   lng = result['geometry']['location']['lng']
    #   google_rating = result['rating']
    #   # puts "result: #{result}"
    #   fb_result = fb_service.search_restaurant(result['name'])
    #   fb_location = fb_service.get_location(fb_result['id']) if fb_result.present?
    #   if fb_location.present?
    #     if fb_location.dig('location','street').present?
    #       fb_street = "地址：#{fb_location.dig('location','street')}"
    #     else
    #       fb_street = ''
    #     end
    #   else
    #     fb_street = ''
    #   end
    #   # puts "fb_result: #{fb_result}"
    #   if fb_location.present?
    #     if fb_location["overall_star_rating"].present? && fb_location["overall_star_rating"].to_i >0
    #       fb_score = "fb評分：#{fb_location['overall_star_rating']}"
    #     else
    #       fb_score = ""
    #     end
    #   else
    #     fb_score = ""
    #   end
    #   fb_image_url = fb_service.photo(fb_result['id']) if fb_result.present?
    #   image_url = fb_image_url.present? ? fb_image_url : test_image_url
      # puts "fb_score: #{fb_score}"
      # fb_score = "fb評分：4"
    results.each do |result|
      id = result['id']
      name = result['name']
      lat = result['location']['latitude']
      lng = result['location']['longitude']
      rating = result['overall_star_rating']
      rating_count = result['rating_count']
      phone = result['phone']
      image_url = id.present? ? fb_service.get_photo(id) : test_image_url

      columns << {
            thumbnailImageUrl: image_url,
            title: name,
            text: "facebook評分：#{rating}分/#{rating_count}人 \n電話：#{phone}",
            actions: [
              {
                type: "uri",
                label: '地圖點我',
                uri: "https://www.google.com/maps/place/#{lat},#{lng}/@#{lat},#{lng},#{zoom}z/data=!3m1!4b1"
              }
            ]
          }
    end

    carousel_result = {
      type: "template",
      altText: "你看，出來了",
      template: {
        type: "carousel",
        columns: columns
      }
    }
    # puts carousel_result
    return carousel_result
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