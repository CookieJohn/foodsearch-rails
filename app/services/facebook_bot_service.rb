class FacebookBotService
  REJECT_CATEGORY ||= I18n.t('settings.facebook.reject_category')
  API_URL ||= "https://graph.facebook.com/v2.6/me/messages?access_token=#{Settings.facebook.page_access_token}"
  BOT_ID ||= '844639869021578'
  
  attr_accessor :graph, :google, :common, :user
	def initialize
    self.graph  ||= GraphApiService.new
    self.google ||= GoogleMapService.new
    self.common ||= CommonService.new
    self.user ||= nil
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
          senderID = receive_message.dig('sender','id').to_s

          User.create!(facebook_user_id: senderID) if !User.exists?(facebook_user_id: senderID)
          self.user = User.find_by(facebook_user_id: senderID)

          lat = ''
          lng = ''
          if receive_message.dig('message','attachments').present?
            receive_message['message']['attachments'].try(:each) do |location|
              lat = location.dig('payload','coordinates','lat')
              lng = location.dig('payload','coordinates','long')
            end
          end
          
          if senderID != BOT_ID 
            if lat.present?
              keyword = user.last_search['keyword'].present? ? user.last_search['keyword'] : nil
              fb_results = graph.search_places(lat, lng, user, 10, nil, keyword)
              # 傳送餐廳資訊
              messageData = generic_elements(senderID, fb_results)
              results = common.http_post(API_URL, messageData)
              # 傳送詢問訊息
              messageData = get_response(senderID, 'done', nil)
              results = common.http_post(API_URL, messageData)

              user.last_search['keyword'] = '' 
              user.last_search['lat'] = lat
              user.last_search['lng'] = lng
              user.save
            else 
              if quick_reply_payload.present?
                messageData = get_response(senderID, quick_reply_payload, message)
              elsif button_payload.present?
                messageData = get_response(senderID, button_payload, message)
              elsif message.present?
                messageData = get_response(senderID, 'message', message)
              end
              results = common.http_post(API_URL, messageData) if messageData.present?
            end
          end
        end
      end
    end
  end

  def text_format id, text
    { recipient: { id: id },
      message: { text: text }}
  end

  def button url, title
    {
      type: 'web_url',
      url: url,
      title: title
    }
  end

  def generic_elements sender_id, results=nil, google_results=nil

    columns = []

    category_lists = Category.pluck(:id)

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

      description = category
      category_list.sample(2).each do |c|
        description += ", #{c['name']}" if c['name'] != category && !REJECT_CATEGORY.any? {|r| c['name'].include?(r) }
        # new_category = Category.create!(facebook_id: c['id'], facebook_name: c['name']) if !category_lists.any? {|cl| cl.include?(c['id']) }
      end
      image_url = graph.get_photo(id)

      actions = []
      actions << button(common.safe_url(link_url), I18n.t('button.official'))
      actions << button(common.safe_url(google.get_map_link(lat, lng, name, street)),I18n.t('button.location'))
      actions << button(common.safe_url(google.get_google_search(name)),I18n.t('button.related_comment'))

      today_open_time = hours.present? ? graph.get_current_open_time(hours) : I18n.t('empty.no_hours')
      # g_match = {'score' => 0.0, 'match_score' => 0.0}
      # if google_results.present?
      #   google_results.each do |r|
      #     match_score = common.fuzzy_match(r['name'],name)
      #     if match_score >= I18n.t('google.match_score') && match_score > g_match['match_score']
      #       g_match['score'] = r['rating']
      #       g_match['match_score'] = match_score
      #     end
      #   end
      # end

      text = "#{I18n.t('facebook.score')}：#{rating}#{I18n.t('common.score')}/#{rating_count}#{I18n.t('common.people')}" if rating.present?
      # text += ", #{I18n.t('google.score')}：#{g_match['score'].to_f.round(2)}#{I18n.t('common.score')}" if g_match['score'].to_f > 2.0
      text += "\n#{description}"
      text += "\n#{today_open_time}"
      # text += "\n#{phone}"

      text = text[0, 80]

      columns << {
        title: name,
        subtitle: text,
        image_url: image_url,
        buttons: actions
      }
    end

    generic_format = {
      recipient: { id: sender_id },
      message: {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'generic',
            # image_aspect_ratio: 'square',
            elements: columns
          }}}}
    return generic_format
  end

  def get_response id, type, text=nil
    response = case type
    when 'choose_search_type'
      title_text = "請選擇想搜尋的類型，或者直接使用目前位置搜尋。"
      options = [
        {
          content_type: "text",
          title: "咖啡",
          payload: "search_specific_item"
        },
        {
          content_type: "text",
          title: "拉麵",
          payload: "search_specific_item"
        },
        {
          content_type: "text",
          title: "丼飯",
          payload: "search_specific_item"
        },
        { content_type: "location" }
      ]
      quick_replies_format(id, text, title_text, options)
    when 'search_specific_item'
      user.last_search['keyword'] = text
      user.save
      title_text = "您搜尋的是： #{text}\n請告訴我你的位置(需開啟定位)，或者移動到您想查詢的位置。"
      options = [
        {
          content_type: "text",
          title: "使用上次的位置",
          payload: "last_location"
        }, 
        { content_type: "location" },
        {
          content_type: "text",
          title: "重新選擇類型",
          payload: "choose_search_type"
        }
      ]
      quick_replies_format(id, text, title_text, options)
    when 'direct_search'
      title_text = "請告訴我你的位置(需開啟定位)，或者移動到您想查詢的位置。"
      options = [
        {
          content_type: "text",
          title: "使用上次的位置",
          payload: "last_location"
        }, 
        { content_type: "location" } ]
      quick_replies_format(id, text, title_text, options)
    when 'last_location'
      if user.last_search['lat'].present?
        lat = user.last_search['lat']
        lng = user.last_search['lng']
        keyword = user.last_search['keyword'].present? ? user.last_search['keyword'] : nil
        fb_results = graph.search_places(lat, lng, user, 10, nil, keyword)
        if user.last_search['keyword'].present?
          user.last_search['keyword'] = '' 
          user.save
        end
        # 傳送餐廳資訊
        messageData = generic_elements(id, fb_results)
        results = common.http_post(API_URL, messageData)
        # 傳送詢問訊息
        messageData = get_response(id, 'done', nil)
        results = common.http_post(API_URL, messageData)
      else
        messageData = get_response(id, 'no_last_location', nil)
        results = common.http_post(API_URL, messageData)
      end
    when 'done'
      title_text = "搜尋結果滿意嗎？或是您想重新搜尋？"
      options = [ 
        { content_type: "location" },
        {
          content_type: "text",
          title: "重新選擇類型",
          payload: "choose_search_type"
        } ]
      quick_replies_format(id, text, title_text, options)
    when 'no_last_location'
      title_text = "您沒有搜尋過唷！"
      options = [ 
        { content_type: "location" },
        {
          content_type: "text",
          title: "重新選擇類型",
          payload: "choose_search_type"
        } ]
      quick_replies_format(id, text, title_text, options)
    else
      title_text = "請選擇："
      options = [
        {
          type: 'postback',
          title: "選擇搜尋類型",
          payload: "choose_search_type"
        },
        {
          type: 'postback',
          title: "直接搜尋",
          payload: "direct_search"
        },
        {
          type: 'web_url',
          url: "https://johnwudevelop.tk/",
          title: "搜尋設定",
          webview_height_ratio: "tall"
        }
      ]
      button_format(id, text, title_text, options)
    end
  end

  def quick_replies_format id, text, title_text=nil, quick_reply_options=nil
    { recipient: { id: id },
      message: {
        text: title_text,
        quick_replies: quick_reply_options}
    }
  end

  def button_format id, text, title_text=nil, button_options=nil
    { recipient: { id: id },
      message: {
        attachment: {
          type: "template",
          payload: {
            template_type: "button",
            text: title_text,
            buttons: button_options }}}
    }
  end
end