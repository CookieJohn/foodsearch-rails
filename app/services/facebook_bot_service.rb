class FacebookBotService < BaseService
  include FacebookFormat
  include Conversion

  API_URL ||= "https://graph.facebook.com/v2.6/me/messages?access_token=#{ENV['facebook_page_access_token']}".freeze
  BOT_ID  ||= '844639869021578'.freeze

  def initialize
    @graph     ||= GraphApiService.new
    @google    ||= GoogleMapService.new
    @user      ||= nil
    @user_id   ||= '1'
    @sender_id ||= nil
    @lat       ||= nil
    @lng       ||= nil
  end

  def reply_msg request
    body = JSON.parse(request.body.read)
    entries = body['entry']

    return if not_fb_message?(body)

    entries.each do |entry|
      entry['messaging'].each do |receive_message|
        return if is_bot?(receive_message)

        message      = receive_message.dig('message', 'text')
        message_type = case
                       when receive_message.dig('message', 'quick_reply')
                         receive_message.dig('message', 'quick_reply', 'payload')
                       when receive_message.dig('postback')
                         receive_message.dig('postback', 'payload')
                       when receive_message.dig('message', 'attachments')
                         location_setting(receive_message)
                         return search_by_location
                       when receive_message.dig('message', 'text')
                         'message'
                       end

        message_data = get_response(message_type, message) if message_type.present?
        http_post(API_URL, message_data) if message_data.present?
      end
    end
  end

  private

  def get_response type, text=nil
    if get_redis_data(@user_id, 'customize') == true
      if type == 'message'
        type = 'search_specific_item'
      else
        redis_set_user_data(@user_id, 'customize', false)
        clear_keyword
      end
    else
      if type != 'last_location' && get_redis_data(@user_id, 'keyword').present?
        clear_keyword
      end
    end
    case type
    when 'choose_search_type'
      title_text = I18n.t('messenger.please-enter-keyword')
      options = []
      options << quick_replies_option(I18n.t('messenger.enter-keyword'), 'customized_keyword')
      I18n.t('settings.facebook.search_texts').each do |search_text|
        options << quick_replies_option(search_text, 'search_specific_item')
      end
      options << quick_replies_option(I18n.t('messenger.all'), 'direct_search')
      options << quick_replies_option(I18n.t('messenger.menu'), 'back')
      quick_replies_format(title_text, options)
    when 'customized_keyword'
      redis_set_user_data(@user_id, 'customize', true)
      title_text = '請輸入你想查詢的關鍵字：'
      options = []
      options << quick_replies_option(I18n.t('messenger.re-select'), 'choose_search_type')
      options << quick_replies_option(I18n.t('messenger.menu'), 'back')
      quick_replies_format(title_text, options)
    when 'search_specific_item'
      redis_set_user_data(@user_id, 'keyword', text)
      redis_set_user_data(@user_id, 'customize', false)
      title_text = "你想找的是： #{text}\n請告訴我你的位置。"
      options = []
      options << quick_replies_option(I18n.t('messenger.last-location'), 'last_location') if get_redis_data(@user_id, 'lat')
      options << send_location
      options << quick_replies_option(I18n.t('messenger.re-select'), 'choose_search_type')
      options << quick_replies_option(I18n.t('messenger.menu'), 'back')
      quick_replies_format(title_text, options)
    when 'direct_search'
      MessengerBotResponse.for(@sender_id, 'direct_search')
    when 'last_location'
      return MessengerBotResponse.for(@sender_id, 'no_last_location') unless get_redis_data(@user_id, 'lat').present?

      @lat = get_redis_data(@user_id, 'lat')
      @lng = get_redis_data(@user_id, 'lng')
      search_by_location
    else
      MessengerBotResponse.for(@sender_id)
    end
  end

  def not_fb_message?(body)
    body.dig('object') != 'page'
  end

  def is_bot?(receive_message)
    @sender_id = receive_message.dig('sender', 'id')
    return if @sender_id == BOT_ID
    user_setting
  end

  def user_setting
    # User.create!(facebook_user_id: @sender_id) unless User.exists?(facebook_user_id: @sender_id)
    # @user = User.find_by(facebook_user_id: @sender_id)
    redis_initialize_user(@user_id) unless redis_key_exist?(@user_id)
  end

  def location_setting(receive_message)
    return if receive_message.dig('message', 'attachments').blank?

    receive_message['message']['attachments'].try(:each) do |location|
      @lat = location.dig('payload', 'coordinates', 'lat')
      @lng = location.dig('payload', 'coordinates', 'long')

      record_lat_lng(@lat, @lng)
    end
  end

  def search_by_location
    return unless @lat.present? && @lng.present?

    keyword = get_redis_data(@user_id, 'keyword')
    fb_results = @graph.search_places(@lat, @lng, user: @user, size: 10, keyword: keyword)
    if fb_results.size.positive?
      message_data = generic_elements(fb_results)
      http_post(API_URL, message_data)
      message_data = MessengerBotResponse.for(@sender_id, 'done')
      http_post(API_URL, message_data)

      clear_keyword
    else
      message_data = MessengerBotResponse.for(@sender_id, 'no_result')
      http_post(API_URL, message_data)
    end
  end

  def clear_keyword
    redis_set_user_data(@user_id, 'keyword', '')
  end

  def record_lat_lng(lat = nil, lng = nil)
    redis_set_user_data(@user_id, 'lat', lat)
    redis_set_user_data(@user_id, 'lng', lng)
  end
end
