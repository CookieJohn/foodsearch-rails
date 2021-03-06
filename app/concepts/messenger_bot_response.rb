# frozen_string_literal: true

module MessengerBotResponse
  class DefaultResponse
    include FacebookFormat

    attr_accessor :options, :title, :msg

    def initialize(sender_id, msg = nil)
      @sender_id = sender_id
      @options   = []
      @title     = ''
      @msg       = msg
    end

    def perform
      title = I18n.t('messenger.menu-title')
      options << button_option('postback', I18n.t('messenger.buttons.choose_search_type'), 'choose_search_type')
      options << button_option('postback', I18n.t('messenger.buttons.keyword_search_type'), 'customized_keyword')
      button_format(title, options)
    end

    private

    def choose_search_reply
      quick_replies_option(I18n.t('messenger.re-select'), 'choose_search_type')
    end

    def last_location_reply
      quick_replies_option(I18n.t('messenger.last-location'), 'last_location') if get_redis_data(@user_id, 'lat')
    end

    def customized_reply
      quick_replies_option(I18n.t('messenger.enter-keyword'), 'customized_keyword')
    end

    def back_reply
      quick_replies_option(I18n.t('messenger.menu'), 'back')
    end
  end

  class ChooseSearchType < DefaultResponse
    def perform
      title = I18n.t('messenger.please-enter-keyword')
      options << customized_reply
      I18n.t('settings.facebook.search_texts').each do |search_text|
        options << quick_replies_option(search_text, 'search_specific_item')
      end
      options << quick_replies_option(I18n.t('messenger.all'), 'direct_search')
      options << back_reply
      quick_replies_format(title, options)
    end
  end

  class SearchSpecificItem < DefaultResponse
    def perform
      title   = I18n.translate('messenger.search_specity', msg: msg)
      options = [last_location_reply, send_location, choose_search_reply, back_reply]
      quick_replies_format(title, options)
    end
  end

  class CustomizedKeyword < DefaultResponse
    def perform
      title   = I18n.t('messenger.your-keyword')
      options = [choose_search_reply, back_reply]
      quick_replies_format(title, options)
    end
  end

  class NoResult < DefaultResponse
    def perform
      title   = I18n.translate('messenger.no-results', keyword: get_redis_data(@user_id, 'keyword'))
      options = [customized_reply, choose_search_reply, back_reply]
      quick_replies_format(title, options)
    end
  end

  class DirectSearch < DefaultResponse
    def perform
      title   = I18n.t('messenger.your-location')
      options = [last_location_reply, send_location]
      quick_replies_format(title, options)
    end
  end

  class NoLastLocation < DefaultResponse
    def perform
      title   = I18n.t('messenger.never-search')
      options = [send_location, choose_search_reply, back_reply]
      quick_replies_format(title, options)
    end
  end

  class SearchDone < DefaultResponse
    def perform
      title   = I18n.t('messenger.like-results')
      options = [customized_reply, choose_search_reply, back_reply]
      quick_replies_format(title, options)
    end
  end

  TYPE_CLASSES = {
    'choose_search_type' => ChooseSearchType,
    'search_specific_item' => SearchSpecificItem,
    'customized_keyword' => CustomizedKeyword,
    'direct_search' => DirectSearch,
    'done' => SearchDone,
    'no_result' => NoResult,
    'no_last_location' => NoLastLocation
  }.freeze

  def self.for(sender_id, type = nil, msg = nil)
    (TYPE_CLASSES[type] || DefaultResponse).new(sender_id, msg).perform
  end
end
