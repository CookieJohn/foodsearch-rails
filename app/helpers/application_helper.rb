# frozen_string_literal: true

module ApplicationHelper
  def on_production?
    Rails.env.production?
  end

  def truncate_utf8(text = nil, length = nil)
    if text.present?
      sacn_string = /[a-z,A-Z,0-9,&, ,.]/
      en_size = text.scan(sacn_string).size
      cut_size = (en_size % 6).zero? ? en_size / 6 : en_size / 6 + 1
      limit_length = length * 3 - cut_size * 3
      omitted_word = limit_length < text.bytesize ? '...' : ''
      text = text.mb_chars.limit(limit_length).to_s + omitted_word
    end
    text
  end

  def search_types
    [
      [i18n_search('restaurant'), 'restaurant'],
      [i18n_search('coffee'), 'coffee']
      # [i18n_search('rice'), i18n_search('rice')],
      # [i18n_search('noodle'), i18n_search('noodle')],
      # [i18n_search('pot'), i18n_search('pot')],
    ]
  end

  def card_types
    [[i18n_label('list'), 'list'], [i18n_label('card'), 'card']]
  end

  def sort_types
    [[i18n_label('score'), 'score'], [i18n_label('distance'), 'distance']]
  end

  def fanpage_link(url)
    browser.mobile? ? url.gsub('www', 'm') : url
  end
end
