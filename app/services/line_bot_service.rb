require 'active_support'
require 'line/bot'

class LineBotService

  COMMANDS ||= [I18n.t('common.user'), I18n.t('common.command'), I18n.t('common.radius'), I18n.t('common.point'), I18n.t('common.random')]
  REJECT_CATEGORY ||= I18n.t('settings.facebook.reject_category')

  attr_accessor :client, :graph, :google, :common
  def initialize
    self.client ||= Line::Bot::Client.new { |config|
      config.channel_secret = Settings.line.channel_secret
      config.channel_token = Settings.line.channel_token
    }
    self.graph  ||= GraphApiService.new
    self.google ||= GoogleMapService.new
    self.common ||= CommonService.new
  end

  def reply_msg request

    self.varify_signature(request)
    
    body = request.body.read

    return_msg = ''
    command = ''
    events = client.parse_events_from(body)
    events.each { |event|

      user_id = event['source']['userId']
      User.create!(line_user_id: user_id) if !User.exists?(line_user_id: user_id)
      user = User.find_by(line_user_id: user_id)

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          msg = event.message['text'].to_s.downcase
          if COMMANDS.any? {|c| msg.include?(c); command = c if msg.include?(c); }
            return_msg = self.handle_with_commands(msg, command, user)
          end
          client.reply_message(event['replyToken'], self.text_format(return_msg)) if return_msg.present?
        when Line::Bot::Event::MessageType::Location
          lat = event.message['latitude']
          lng = event.message['longitude']
          fb_results = graph.search_places(lat, lng, user)
          google_results = ''
          if user.get_google_result
            keywords = fb_results.map {|f| f['name']}
            google_results = google.search_places(lat, lng, user, keywords)
          end
          return_response = (fb_results.size>0) ? self.carousel_format(fb_results, google_results) : self.text_format(I18n.t('empty.no_restaurants'))
          client.reply_message(event['replyToken'], return_response)
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

    columns = []

    results.each do |result|
      id = result['id']
      name = result['name'][0, 40]
      lat = result['location']['latitude']
      lng = result['location']['longitude']
      street = result['location']['street'] || ""
      rating = result['overall_star_rating']
      rating_count = result['rating_count']
      # phone = result.dig('phone').present? ? result['phone'].gsub('+886','0') : "00000000"
      link_url = result['link'] || result['website']
      category = result['category']
      category_list = result['category_list']
      hours = result['hours']

      description = category
      category_list.sample(2).each do |c|
        description += ", #{c['name']}" if c['name'] != category && !REJECT_CATEGORY.any? {|r| c['name'].include?(r) }
        new_category = Category.create!(facebook_id: c['id'], facebook_name: c['name']) if !Category.exists?(facebook_id: c['id'])
      end
      image_url = graph.get_photo(id)

      actions = []
      actions << set_action(I18n.t('button.official'), common.safe_url(link_url))
      actions << set_action(I18n.t('button.location'), common.safe_url(google.get_map_link(lat, lng, name, street)))
      actions << set_action(I18n.t('button.related_comment'), common.safe_url(google.get_google_search(name)))

      today_open_time = hours.present? ? graph.get_current_open_time(hours) : I18n.t('empty.no_hours')
      g_match = {'score' => 0.0, 'match_score' => 0.0}
      if google_results.present?
        google_results.each do |r|
          match_score = common.fuzzy_match(r['name'],name)
          if match_score >= I18n.t('google.match_score') && match_score > g_match['match_score']
            g_match['score'] = r['rating']
            g_match['match_score'] = match_score
          end
        end
      end

      text = ""
      text += "#{I18n.t('facebook.score')}：#{rating}#{I18n.t('common.score')}/#{rating_count}#{I18n.t('common.people')}" if rating.present?
      text += ", #{I18n.t('google.score')}：#{g_match['score'].to_f.round(2)}#{I18n.t('common.score')}" if g_match['score'].to_f > 2.0
      text += "\n#{description}"
      text += "\n#{today_open_time}"

      text = text[0, 60]

      columns << {
        thumbnailImageUrl: image_url,
        title: name,
        text: text,
        actions: actions
      }
    end

    carousel_result = {
      type: "template",
      altText: I18n.t('carousel.text'),
      template: {
        type: "carousel",
        columns: columns
      }
    }
    # Rails.logger.info "CAROUSEL_RESULT: #{carousel_result}"
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
    when I18n.t('common.user')
      "#{I18n.t('common.user')}#{I18n.t('common.setting')}：\n#{I18n.t('common.radius')}：#{user.try(:max_distance)}m\n#{I18n.t('common.point')}：#{user.try(:min_score)}#{I18n.t('common.score')}\n#{I18n.t('common.random')}：#{user.random_type ? I18n.t('common.open') : I18n.t('common.close')}"
    when I18n.t('common.command')
      "#{I18n.t('common.command')}#{I18n.t('common.setting')}：\n#{I18n.t('common.random')}：#{I18n.t('common.random')}true/false\n#{I18n.t('common.radius')}500(500~50000)\n#{I18n.t('common.point')}3.8 (3~5 接受小數第一位)"
    when I18n.t('common.random')
      random = msg.gsub(command, '').to_s
      set_random = (random == I18n.t('common.open')) ? true : false
      user.random_type = set_random
      if random == I18n.t('common.open') || random == I18n.t('common.close')
        if user.save
          "#{I18n.t('command.success')}，#{I18n.t('common.random')}：#{random}"
        else
          I18n.t('command.error')
        end
      else
        I18n.t('command.error')
      end
    when I18n.t('common.radius')
      radius = msg.gsub(command, '').to_i
      user.max_distance = radius
      if user.save
        "#{I18n.t('command.success')}，#{I18n.t('common.radius')}：#{radius}m"
      else
        I18n.t('command.error')
      end
    when I18n.t('common.point')
      score = msg.gsub(command, '').to_f
      user.min_score = score
      if user.save
        "#{I18n.t('command.success')}，#{I18n.t('common.point')}：#{score}"
      else
        I18n.t('command.error')
      end
    end
  end
end