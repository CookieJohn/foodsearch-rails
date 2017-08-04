require 'line/bot'

class LineBotService

  REJECT_CATEGORY ||= I18n.t('settings.facebook.reject_category')

  attr_accessor :client, :graph, :google, :common, :user
  def initialize
    self.client ||= Line::Bot::Client.new { |config|
      config.channel_secret = Settings.line.channel_secret
      config.channel_token = Settings.line.channel_token
    }
    self.graph  ||= GraphApiService.new
    self.google ||= GoogleMapService.new
    self.common ||= CommonService.new
    self.user ||= nil
  end

  def reply_msg request

    varify_signature(request)
    
    body = request.body.read

    return_msg = ''
    events = client.parse_events_from(body)
    events.each { |event|

      user_id = event['source']['userId']
      User.create!(line_user_id: user_id) if !User.exists?(line_user_id: user_id)
      self.user = User.find_by(line_user_id: user_id)

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          msg = event.message['text'].downcase
          client.reply_message(event['replyToken'], text_format(msg))
        when Line::Bot::Event::MessageType::Location
          lat = event.message['latitude']
          lng = event.message['longitude']
          facebook_results = graph.search_places(lat, lng, user)
          if facebook_results.size > 0
            options = carousel_options(facebook_results)
            return_response = carousel_format(options)
          else
            return_response = text_format(I18n.t('empty.no_restaurants'))
          end
          client.reply_message(event['replyToken'], return_response)
        end
      end
    }
    return return_msg
  end

  def text_format return_msg
    { type: 'text',
      text: return_msg }
  end

  def carousel_format columns
    { type: "template",
      altText: I18n.t('carousel.text'),
      template: {
        type: "carousel",
        columns: columns }}
  end

  def set_action text, link
    { type: "uri",
      label: text,
      uri: link }
  end

  def varify_signature request
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    return '400 Bad Request' unless client.validate_signature(body, signature)
  end

  def carousel_options results
    columns = []
    # category_lists = Category.pluck(:id)

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
        # new_category = Category.create!(facebook_id: c['id'], facebook_name: c['name']) if !category_lists.any? {|cl| cl.include?(c['id']) }
      end
      image_url = graph.get_photo(id)

      actions = []
      actions << set_action(I18n.t('button.official'), common.safe_url(link_url))
      actions << set_action(I18n.t('button.location'), common.safe_url(google.get_map_link(lat, lng, name, street)))
      actions << set_action(I18n.t('button.related_comment'), common.safe_url(google.get_google_search(name)))

      today_open_time = hours.present? ? graph.get_current_open_time(hours) : I18n.t('empty.no_hours')

      text = "#{I18n.t('facebook.score')}：#{rating}#{I18n.t('common.score')}/#{rating_count}#{I18n.t('common.people')}" if rating.present?
      text += "\n#{description}"
      text += "\n#{today_open_time}"
      # text += "\n#{phone}"

      text = text[0, 60]

      columns << {
        thumbnailImageUrl: image_url,
        title: name,
        text: text,
        actions: actions }
    end
    return columns
  end
end