module MessengerBotResponse
  def self.for(sender_id, type = nil, msg = nil)
    subject = case type
              when 'choose_search_type'
                ChooseSearchType
              when 'search_specific_item'
                SearchSpecificItem
              when 'customized_keyword'
                CustomizedKeyword
              when 'direct_search'
                DirectSearch
              when 'done'
                SearchDone
              when 'no_result'
                NoResult
              when 'no_last_location'
                NoLastLocation
              else
                DefaultResponse
              end

    subject.new(sender_id, msg).reply
  end
end

class DefaultResponse
  include FacebookFormat

  attr_accessor :options, :title, :msg

  def initialize(sender_id, msg = nil)
    @sender_id = sender_id
    @options   = []
    @title     = ''
    @msg       = msg
  end

  def reply
    title   = '請選擇搜尋方式，設定頁面可以調整搜尋條件。'
    options << button_option('postback', '選擇搜尋類型', 'choose_search_type')
    options << button_option('postback', '關鍵字搜尋', 'customized_keyword')
    # options << button_link_option("https://johnwudevelop.tk/users/#{@user_id}", '搜尋設定')
    button_format(title, options)
  end

  private

  def choose_search_reply
    quick_replies_option(I18n.t('messenger.re-select'), 'choose_search_type')
  end

  def last_location_reply
    quick_replies_option(I18n.t('messenger.last-location'), 'last_location') if get_redis_data(@user_id, 'lat')
  end

  def back_reply
    quick_replies_option(I18n.t('messenger.menu'), 'back')
  end
end

class ChooseSearchType < DefaultResponse
  def reply
    title   = I18n.t('messenger.please-enter-keyword')
    options << quick_replies_option(I18n.t('messenger.enter-keyword'), 'customized_keyword')
    I18n.t('settings.facebook.search_texts').each do |search_text|
      options << quick_replies_option(search_text, 'search_specific_item')
    end
    options << quick_replies_option(I18n.t('messenger.all'), 'direct_search')
    options << back_reply
    quick_replies_format(title, options)
  end
end

class SearchSpecificItem < DefaultResponse
  def reply
    title   = "你想找的是： #{msg}\n請告訴我你的位置。"
    options = [last_location_reply, send_location, choose_search_reply, back_reply]
    quick_replies_format(title, options)
  end
end

class CustomizedKeyword < DefaultResponse
  def reply
    title   = '請輸入你想查詢的關鍵字：'
    options = [choose_search_reply, back_reply]
    quick_replies_format(title, options)
  end
end

class NoResult < DefaultResponse
  def reply
    title   = "這個位置，沒有與#{get_redis_data(@user_id, 'keyword')}相關的搜尋結果！"
    options = [choose_search_reply, back_reply]
    quick_replies_format(title, options)
  end
end

class DirectSearch < DefaultResponse
  def reply
    title   = I18n.t('messenger.your-location')
    options << [last_location_reply, send_location]
    quick_replies_format(title, options)
  end
end

class NoLastLocation < DefaultResponse
  def reply
    title   = '您沒有搜尋過唷！'
    options = [send_location, choose_search_reply, back_reply]
    quick_replies_format(title, options)
  end
end

class SearchDone < DefaultResponse
  def reply
    title   = '有找到喜歡的嗎？'
    options << quick_replies_option(I18n.t('messenger.enter-keyword'), 'customized_keyword')
    options << choose_search_reply
    options << back_reply
    quick_replies_format(title, options)
  end
end
