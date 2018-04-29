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
                         return search_by_location if @lat.present? && @lng.present?
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
        redis_set_user_data(@user_id, 'keyword', '')
      end
    else
      if type != 'last_location' && get_redis_data(@user_id, 'keyword').present?
        redis_set_user_data(@user_id, 'keyword', '')
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
      title_text = I18n.t('messenger.your-location')
      options = []
      options << quick_replies_option(I18n.t('messenger.last-location'), 'last_location') if get_redis_data(@user_id, 'lat')
      options << send_location
      quick_replies_format(title_text, options)
    when 'last_location'
      if get_redis_data(@user_id, 'lat').present?
        @lat = get_redis_data(@user_id, 'lat')
        @lng = get_redis_data(@user_id, 'lng')
        search_by_location
      else
        message_data = get_response('no_last_location', nil)
        http_post(API_URL, message_data)
      end
    when 'done'
      title_text = '有找到喜歡的嗎？'
      options = []
      options << quick_replies_option(I18n.t('messenger.enter-keyword'), 'customized_keyword')
      options << quick_replies_option(I18n.t('messenger.re-select'), 'choose_search_type')
      options << quick_replies_option(I18n.t('messenger.menu'), 'back')
      quick_replies_format(title_text, options)
    when 'no_last_location'
      title_text = '您沒有搜尋過唷！'
      options = []
      options << send_location
      options << quick_replies_option(I18n.t('messenger.re-select'), 'choose_search_type')
      options << quick_replies_option(I18n.t('messenger.menu'), 'back')
      quick_replies_format(title_text, options)
    when 'no_result'
      title_text = "這個位置，沒有與#{get_redis_data(@user_id, 'keyword')}相關的搜尋結果！"
      options = []
      options << quick_replies_option(I18n.t('messenger.re-select'), 'choose_search_type')
      options << quick_replies_option(I18n.t('messenger.menu'), 'back')
      quick_replies_format(title_text, options)
    else
      title_text = '請選擇搜尋方式，設定頁面可以調整搜尋條件。'
      options = []
      options << button_option('postback', '選擇搜尋類型', 'choose_search_type')
      options << button_option('postback', '關鍵字搜尋', 'customized_keyword')
      options << button_link_option("https://johnwudevelop.tk/users/#{@user_id}", '搜尋設定')
      button_format(title_text, options)
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

      redis_set_user_data(@user_id, 'lat', @lat)
      redis_set_user_data(@user_id, 'lng', @lng)
    end
  end

  def search_by_location
    keyword = get_redis_data(@user_id, 'keyword')
    fb_results = @graph.search_places(@lat, @lng, user: @user, size: 10, keyword: keyword)
    if fb_results.size.positive?
      message_data = generic_elements(fb_results)
      http_post(API_URL, message_data)
      message_data = get_response('done', nil)
      http_post(API_URL, message_data)

      redis_set_user_data(@user_id, 'keyword', '')
      redis_set_user_data(@user_id, 'lat', @lat)
      redis_set_user_data(@user_id, 'lng', @lng)
    else
      message_data = get_response('no_result', nil)
      http_post(API_URL, message_data)
    end
  end
end
