class FacebookBotService < BaseService
  include FacebookFormat
  include Conversion

  API_URL ||= "https://graph.facebook.com/v2.6/me/messages?access_token=#{ENV['facebook_page_access_token']}"
  BOT_ID ||= '844639869021578'

  def initialize
    @graph  ||= GraphApiService.new
    @google ||= GoogleMapService.new
    @user ||= nil
  end

  def reply_msg request
    body = JSON.parse(request.body.read)
    entries = body['entry']

    if body.dig('object') == 'page'
      entries.each do |entry|
        entry['messaging'].each do |receive_message|
          message = receive_message.dig('message','text')
          button_payload = receive_message.dig('postback','payload')
          button_payload_title = receive_message.dig('postback','title')
          quick_reply_payload = receive_message.dig('message','quick_reply','payload')
          quick_reply_payload_title = receive_message.dig('message','quick_reply','title')
          senderID = receive_message.dig('sender','id')

          if senderID != BOT_ID
            User.create!(facebook_user_id: senderID) if !User.exists?(facebook_user_id: senderID)
            @user = User.find_by(facebook_user_id: senderID)
            redis_initialize_user(@user.id) if !redis_key_exist?(@user.id)

            lat = ''
            lng = ''
            if receive_message.dig('message','attachments').present?
              receive_message['message']['attachments'].try(:each) do |location|
                lat = location.dig('payload','coordinates','lat')
                lng = location.dig('payload','coordinates','long')
              end
            end

            if lat.present?
              keyword = get_redis_data(@user.id, 'keyword')
              fb_results = @graph.search_places(lat, lng, user: @user, size: 10, keyword: keyword)
              if fb_results.size > 0
                # 傳送餐廳資訊
                messageData = generic_elements(senderID, fb_results)
                results = http_post(API_URL, messageData)
                # 傳送詢問訊息
                messageData = get_response(senderID, 'done', nil)
                results = http_post(API_URL, messageData)

                redis_set_user_data(@user.id, 'keyword', '')
                redis_set_user_data(@user.id, 'lat', lat)
                redis_set_user_data(@user.id, 'lng', lng)
              else
                messageData = get_response(senderID, 'no_result', nil)
                results = http_post(API_URL, messageData)
              end
            else
              if quick_reply_payload.present?
                messageData = get_response(senderID, quick_reply_payload, message)
              elsif button_payload.present?
                messageData = get_response(senderID, button_payload, message)
              elsif message.present?
                messageData = get_response(senderID, 'message', message)
              end
              results = http_post(API_URL, messageData) if messageData.present?
            end
          else
            false
          end
        end
      end
    end
  end

  def generic_elements sender_id, results=nil
    columns = []

    results.each do |result|
      r = format(result)
      r.text = set_text(r, 'facebook')

      actions = []
      actions << button(safe_url(r.link_url), I18n.t('button.official'))
      actions << button(safe_url(@google.get_map_link(r.lat, r.lng, r.name, r.street)),I18n.t('button.location'))
      actions << button(safe_url(@google.get_google_search(r.name)),I18n.t('button.related_comment'))

      columns << {
        title: r.name,
        subtitle: r.text,
        image_url: r.image_url,
        buttons: actions }
    end

    generic_format = {
      recipient: { id: sender_id },
      message: {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'generic',
            elements: columns
          }}}}
    return generic_format
  end

  def get_response id, type, text=nil
    if get_redis_data(@user.id, 'customize') == true
      if type == 'message'
        type = 'search_specific_item'
      else
        redis_set_user_data(@user.id, 'customize', false)
        redis_set_user_data(@user.id, 'keyword', '')
      end
    else
      if type != 'last_location'
        if get_redis_data(@user.id, 'keyword').present?
          redis_set_user_data(@user.id, 'keyword', '')
        end
      end
    end
    response = case type
               when 'choose_search_type'
                 title_text = I18n.t('messenger.please-enter-keyword')
                 options = []
                 options << quick_replies_option(I18n.t('messenger.enter-keyword'), 'customized_keyword')
                 I18n.t('settings.facebook.search_texts').each do |search_text|
                   options << quick_replies_option(search_text, 'search_specific_item')
                 end
                 options << quick_replies_option(I18n.t('messenger.all'), 'direct_search')
                 options << quick_replies_option(I18n.t('messenger.menu'), 'back')
                 quick_replies_format(id, text, title_text, options)
               when 'customized_keyword'
                 redis_set_user_data(@user.id, 'customize', true)
                 title_text = '請輸入你想查詢的關鍵字：'
                 options = []
                 options << quick_replies_option(I18n.t('messenger.re-select'), 'choose_search_type')
                 options << quick_replies_option(I18n.t('messenger.menu'), 'back')
                 quick_replies_format(id, text, title_text, options)
               when 'search_specific_item'
                 redis_set_user_data(@user.id, 'keyword', text)
                 redis_set_user_data(@user.id, 'customize', false)
                 title_text = "你想找的是： #{text}\n請告訴我你的位置。"
                 options = []
                 options << quick_replies_option(I18n.t('messenger.last-location'), 'last_location') if get_redis_data(@user.id, 'lat')
                 options << send_location
                 options << quick_replies_option(I18n.t('messenger.re-select'), 'choose_search_type')
                 options << quick_replies_option(I18n.t('messenger.menu'), 'back')
                 quick_replies_format(id, text, title_text, options)
               when 'direct_search'
                 title_text = I18n.t('messenger.your-location')
                 options = []
                 options << quick_replies_option(I18n.t('messenger.last-location'), 'last_location') if get_redis_data(@user.id, 'lat')
                 options << send_location
                 quick_replies_format(id, text, title_text, options)
               when 'last_location'
                 if get_redis_data(@user.id, 'lat').present?
                   lat = get_redis_data(@user.id, 'lat')
                   lng = get_redis_data(@user.id, 'lng')
                   keyword = get_redis_data(@user.id, 'keyword')
                   fb_results = @graph.search_places(lat, lng, user: @user, size: 10, keyword: keyword)
                   if fb_results.size > 0
                     redis_set_user_data(@user.id, 'keyword', '') if get_redis_data(@user.id, 'keyword').present?
                     # 傳送餐廳資訊
                     messageData = generic_elements(id, fb_results)
                     results = http_post(API_URL, messageData)
                     # 傳送詢問訊息
                     messageData = get_response(id, 'done', nil)
                     results = http_post(API_URL, messageData)
                   else
                     messageData = get_response(id, 'no_result', nil)
                     results = http_post(API_URL, messageData)
                   end
                 else
                   messageData = get_response(id, 'no_last_location', nil)
                   results = http_post(API_URL, messageData)
                 end
               when 'done'
                 title_text = "有找到喜歡的嗎？"
                 options = []
                 options << quick_replies_option(I18n.t('messenger.enter-keyword'), 'customized_keyword')
                 options << quick_replies_option(I18n.t('messenger.re-select'), 'choose_search_type')
                 options << quick_replies_option(I18n.t('messenger.menu'), 'back')
                 quick_replies_format(id, text, title_text, options)
               when 'no_last_location'
                 title_text = "您沒有搜尋過唷！"
                 options = []
                 options << send_location
                 options << quick_replies_option(I18n.t('messenger.re-select'), 'choose_search_type')
                 options << quick_replies_option(I18n.t('messenger.menu'), 'back')
                 quick_replies_format(id, text, title_text, options)
               when 'no_result'
                 title_text = "這個位置，沒有與#{get_redis_data(@user.id, 'keyword')}相關的搜尋結果！"
                 options = []
                 options << quick_replies_option(I18n.t('messenger.re-select'), 'choose_search_type')
                 options << quick_replies_option(I18n.t('messenger.menu'), 'back')
                 quick_replies_format(id, text, title_text, options)
               else
                 title_text = "請選擇搜尋方式，設定頁面可以調整搜尋條件。"
                 options = []
                 options << button_option('postback', '選擇搜尋類型', 'choose_search_type')
                 options << button_option('postback', '關鍵字搜尋', 'customized_keyword')
                 options << button_link_option("https://johnwudevelop.tk/users/#{@user.id}", '搜尋設定')
                 button_format(id, text, title_text, options)
               end
  end
end
