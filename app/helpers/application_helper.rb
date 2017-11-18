module ApplicationHelper

  def on_production?
    Rails.env.production?
  end

  def truncate_utf8 text=nil, length=nil
    if text.present?
      sacn_string = /[a-z,A-Z,0-9,&, ,.]/
      en_size = text.scan(sacn_string).size
      cut_size = (en_size%6)==0 ? en_size/6 : en_size/6+1
      limit_length = length*3 - cut_size*3
      omitted_word = !(limit_length>=text.bytesize) ? "..." : ""
      text = text.mb_chars.limit(limit_length).to_s + omitted_word
    else
      text
    end
  end

  def search_types
    [[i18n_label('coffee'), 'coffee'], [i18n_label('restaurant'), 'restaurant']]
  end

  def display_types
    [[i18n_label('wrap'), 'wrap'], [i18n_label('nowrap'), 'nowrap']]
  end

  def sort_types
    [[i18n_label('score'), 'score'], [i18n_label('distance'), 'distance']]
  end
end
