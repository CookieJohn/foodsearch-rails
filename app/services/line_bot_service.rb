require 'active_support'
require 'line/bot'
require 'fuzzystringmatch'

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
      user = ''
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
            return_msg = bot.handle_with_commands(msg, command, user)

            client.reply_message(event['replyToken'], bot.text_format(return_msg))
          else
            client.reply_message(event['replyToken'], bot.text_format(''))
          end
        when Line::Bot::Event::MessageType::Location
          # address = event.message['address'].to_s.downcase
          lat = event.message['latitude'].to_s
          lng = event.message['longitude'].to_s
          fb_results = GraphApiService.new.search_places(lat, lng, user)
          # keywords = ""
          # fb_results.select {|f| keywords = keywords.present? ? keywords = "#{keywords},#{f['name']}" : keywords = "#{f['name']}"}
          # google_results = []
          # fb_results.each do |f|
          #   results = GoogleMapService.new.place_search(lat, lng, user, f['name'])
          #   google_results += results
          # end
          # google_results = GoogleMapService.new.place_search(lat, lng, user, keywords)
          if fb_results.size > 0
            client.reply_message(event['replyToken'], bot.carousel_format(fb_results))
          else
            client.reply_message(event['replyToken'], bot.text_format('此區域查無餐廳。'))
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

  def carousel_format results=nil, google_results=nil
   
    test_image_url = 'https://pbs.twimg.com/media/CgzniPeUkAEMkTl.jpg'
    google_service = GoogleMapService.new
    fb_service = GraphApiService.new

    today = Time.now.wday

    columns = []

    jarow = FuzzyStringMatch::JaroWinkler.create(:native)

    results.each do |result|
      id = result['id']
      name = result['name']
      lat = result['location']['latitude']
      lng = result['location']['longitude']
      rating = result['overall_star_rating']
      rating_count = result['rating_count']
      phone = result.dig('phone').present? ? result['phone'].gsub('+886','0') : "00000000"
      link_url = result['link']
      category_list = result['category_list']
      hours = result['hours']

      description = ""
      category_list.each_with_index do |c, index|
        description += ', ' if index > 0
        description += c['name']
        if !Category.exists?(facebook_id: c['id'])
          new_category = Category.new(facebook_id: c['id'], facebook_name: c['name'])
          new_category.save
        end
      end
      image_url = id.present? ? fb_service.get_photo(id) : test_image_url

      actions = []
      # actions << set_action('電話聯絡店家', "tel:#{phone}")
      uri = URI.encode(link_url)
      uri = URI.parse(uri)
      actions << set_action('Facebook粉絲團', uri)
      actions << set_action('Google Map', google_service.get_map_link(lat,lng))
      uri = URI.encode(google_service.get_google_search(name))
      uri = URI.parse(uri)
      actions << set_action('Google搜尋結果', uri)

      today_open_time = hours.present? ? fb_service.get_current_open_time(hours, today) : "無提供"
      # Rails.logger.info "today_open_time: #{today_open_time}"
      # # match_google_result = ""
      # match_google_result = {'score' => 0.0, 'match_score' => 0.0}
      # google_results.each do |r|
      #   match_score = jarow.getDistance(r['name'],name).to_f
      #   if match_score >= 0.8 && match_score > match_google_result['match_score']
      #     match_google_result['score'] = r['rating'].to_f.round(2)
      #     match_google_result['match_score'] = match_score
      #   end
      #   Rails.logger.info "判斷字串：#{name}, 比對字串：#{r['name']}, 判斷分數：#{match_score.round(2)}"
      # end

      text = ""
      text += "Fb：#{rating}分/#{rating_count}人" if rating.present?
      # text += " #{phone}" if phone.present?
      # text += "/#{rating_count}人" if rating_count.present?
      # text += ", G：#{match_google_result['score']}分" if match_google_result['score'].to_i > 0
      text += "\n#{description}" if description.present?
      text += "\n時間：#{today_open_time}" if today_open_time.present?
      # text = text.truncate(60)

      columns << {
        thumbnailImageUrl: image_url,
        title: name,
        text: text,
        actions: actions
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
    # Rails.logger.info "carousel_result: #{carousel_result}"
    return carousel_result
  end

  def set_action text, link
    {
      type: "uri",
      label: text,
      uri: link
    }
  end

  def varify_signature request
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    return '400 Bad Request' unless client.validate_signature(body, signature)
  end

  def handle_with_commands msg, command, user
    case command
    when '使用者'
      "使用者設定：\n搜尋最大半徑：#{user.try(:max_distance)}\n搜尋最低評分：#{user.try(:min_score)}\n搜尋類型隨機：#{user.try(:random_type)}"
    when '指令'
      "設定指令：\n設定隨機：隨機=true or false\n距離=500 (500~50000)\n評分=3.8 (2~5 接受小數第一位)"
    when '隨機='
      random = msg.gsub('隨機=', '').to_s
      user.random_type = random
      if random == 'true' || random == 'false'
        if user.save
          "設定成功，隨機模式設為：#{random}。"
        else
          "設定失敗，輸入有誤。"
        end
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
  end
end