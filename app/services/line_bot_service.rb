require 'active_support'
require 'line/bot'

class LineBotService

  COMMANDS ||= ['使用者', '指令', '距離=', '評分=', '隨機=']

  attr_accessor :client
  def initialize
    self.client ||= Line::Bot::Client.new { |config|
      config.channel_secret = Settings.line.channel_secret
      config.channel_token = Settings.line.channel_token
    }
  end

  def reply_msg request
    bot = LineBotService.new
    bot.varify_signature(request)
    
    body = request.body.read

    return_msg = ''
    command = ''
    events = client.parse_events_from(body)
    events.each { |event|
      token = event['replyToken']

      user_id = event['source']['userId']
      if !User.exists?(line_user_id: user_id)
        user = User.create(line_user_id: user_id)
        user.save
      end
      user = User.find_by(line_user_id: user_id)

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          msg = event.message['text'].to_s.downcase
          if COMMANDS.any? {|c| msg.include?(c); command = c if msg.include?(c); }
            return_msg = case command
            when '使用者'
              "使用者設定：\n搜尋最大半徑：#{user.try(:max_distance)}\n搜尋最低評分：#{user.try(:min_score)}\n搜尋類型隨機：#{user.try(:random_type)}"
            when '指令'
              "設定指令：\n設定隨機：隨機=true or false\n距離=500 (500~50000)\n評分=3.8 (2~5 接受小數第一位)"
            when '隨機='
              random = msg.gsub('隨機=', '').to_s
              user.random_type = random
              if random == 'true' || random == 'false' && user.save
                "設定成功，隨機模式設為：#{random}。"
              else
                "設定失敗，輸入有誤。"
              end
            when '距離='
              distance = msg.gsub('距離=', '').to_i
              user.max_distance = distance
              if user.save
                "設定成功，半徑設為：#{distance}m。"
              else
                "設定失敗，輸入有誤。"
              end
            when '評分='
              score = msg.gsub('評分=', '').to_f
              user.min_score = score
              if user.save
                "設定成功，評分設為：#{score}。"
              else
                "設定失敗，輸入有誤。"
              end
            end

            client.reply_message(event['replyToken'], bot.text_format(return_msg))
          else
            client.reply_message(event['replyToken'], bot.text_format(''))
          end
          # client.reply_message(event['replyToken'], bot.text_format(msg))
        when Line::Bot::Event::MessageType::Location
          # address = event.message['address'].to_s.downcase
          lat = event.message['latitude'].to_s
          lng = event.message['longitude'].to_s
          fb_results = GraphApiService.new.search_places(lat, lng, user)
          if fb_results.size > 0
            client.reply_message(token, bot.carousel_format(fb_results))
          else
            client.reply_message(token, bot.text_format('此區域查無餐廳。'))
          end
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          # response = client.get_message_content(event.message['id'])
          # tf = Tempfile.open("content")
          # tf.write(response.body)
        end
      end
    }
    return return_msg
  end

  def text_format return_msg
    {
      type: 'text',
      text: return_msg
    }
  end

  def carousel_format results=nil
   
    test_image_url = 'https://pbs.twimg.com/media/CgzniPeUkAEMkTl.jpg'
    google_service = GoogleMapService.new
    fb_service = GraphApiService.new

    columns = []

    results.each do |result|
      id = result['id']
      name = result['name']
      lat = result['location']['latitude']
      lng = result['location']['longitude']
      rating = result['overall_star_rating']
      rating_count = result['rating_count']
      phone = result['phone']
      link_url = result['link']
      category_list = result['category_list']

      description = ""
      category_list.each_with_index do |c, index|
        description += ', ' if index > 0
        description += c['name']
      end
      image_url = id.present? ? fb_service.get_photo(id) : test_image_url

      columns << {
        thumbnailImageUrl: image_url,
        title: name,
        text: "Facebook評分：#{rating}分/#{rating_count}人 \n類型：#{description}",
        actions: [
          {
            type: "uri",
            label: '電話聯絡店家',
            uri: "tel:#{phone}"
          },
          {
            type: "uri",
            label: 'Facebook粉絲團',
            uri: link_url
          },
          {
            type: "uri",
            label: 'Google Map',
            uri: google_service.get_map_link(lat,lng)
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
    return carousel_result
  end

  def varify_signature request
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    return '400 Bad Request' unless client.validate_signature(body, signature)
  end

end