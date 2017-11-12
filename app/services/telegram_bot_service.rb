class TelegramBotService < BaseService
  TOKEN ||= ENV['telegram_token']
  API_URL ||= "https://api.telegram.org/bot#{TOKEN}/sendMessage"

  attr_accessor :request, :chat_id, :graph, :google, :user
  def initialize request
    self.graph  ||= GraphApiService.new
    self.google ||= GoogleMapService.new
    self.user ||= nil
    self.request ||= request
    self.chat_id ||= chat_id
  end

  def reply_msg
    body = JSON.parse(request.raw_post)
    msg = body.dig('message','text')
    self.chat_id = body.dig('message','chat','id')
    lat = body.dig('message','location','latitude')
    lng = body.dig('message','location','longitude')

    if chat_id.present?
      if lat.present?
        # keyword = user.last_search['keyword'].present? ? user.last_search['keyword'] : nil
        fb_results = graph.search_places(lat, lng, user: user, size: 10)
        generic_format = generic_elements(fb_results)
        if fb_results.size > 0
          response = text_format(generic_format)
        else
          response = text_format('no_result')
        end
      elsif msg.present?
        response = reply_format(msg)
      end
      results = http_post(API_URL, response)
    end
  end

  def text_format text
    { chat_id: chat_id,
      text: text,
      parse_mode: 'Markdown' }
  end

  def html_format text
    { chat_id: chat_id,
      text: text,
      parse_mode: 'HTML' }
  end

  def reply_format text
    { chat_id: chat_id,
      text: text,
      parse_mode: 'Markdown',
      reply_markup: {
        keyboard: [ location_button_format ],
        resize_keyboard: true,
        one_time_keyboard: true }}
  end

  def inline_keyboard_button_format text
    { chat_id: chat_id,
      text: text,
      parse_mode: 'Markdown',
      reply_markup: {
        inline_keyboard: [ link_button_format ],
        resize_keyboard: true,
        one_time_keyboard: true }}
  end

  def link_button_format url
    [ text: '請告訴我您的位置', url: url ]
  end

  def location_button_format
    [ text: '請告訴我您的位置', request_location: true ]
  end

  # def photo_format text
  #   { chat_id: chat_id,
  #     text: text,
  #     parse_mode: 'Markdown',
  #     reply_markup: {
  #       inline_keyboard: [ link_button_format ],
  #       resize_keyboard: true,
  #       one_time_keyboard: true }}
  # end

  def generic_elements results=nil
    columns = []

    return_text = ''

    results.each do |result|
      id = result['id']
      name = result['name'][0, 80]
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
      distance = result['distance'].present? ? "#{result['distance']}公尺" : ''

      description = pick_categories(category, category_list)
      image_url = graph.get_photo(id)

      # actions = []
      # actions << button(safe_url(link_url), I18n.t('button.fanpage'))
      # actions << button(safe_url(google.get_map_link(lat, lng, name, street)),I18n.t('button.location'))
      # actions << button(safe_url(google.get_google_search(name)),I18n.t('button.related_comment'))
      business_hours = hours.present? ? graph.get_current_open_time(hours) : I18n.t('empty.business_hours')

      text = "*#{name}* \n"
      text += "#{I18n.t('facebook.score')}：#{rating}#{I18n.t('common.score')}/#{rating_count}#{I18n.t('common.people')}" if rating.present?
      text += "\n#{description}"
      text += "\n#{business_hours}"
      text += "\n#{distance}"
      text += "\n['圖片'](goo.gl/v9Hfiq)"
      # text += "\n#{phone}"

      text = text[0, 80]

      return_text = text

      # columns << {
      #   title: name,
      #   subtitle: text,
      #   image_url: image_url,
      #   buttons: actions
      # }
    end

    return return_text
  end
end
