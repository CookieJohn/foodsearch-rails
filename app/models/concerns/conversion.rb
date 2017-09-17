module Conversion
  REJECT_CATEGORY ||= I18n.t('settings.facebook.reject_category')

  def facebook_response(result)

    conversion_data = Struct.new(:id, :name, :lat, :lng, :street, :rating,
      :rating_count, :phone, :link_url, :text, :category_list, :category_list_web, :today_open_time,
      :image_url, :distance)
    data = conversion_data.new(
      result['id'],
      result['name'][0, 40],
      result['location']['latitude'],
      result['location']['longitude'],
      result['location']['street'] || "無提供地址",
      result['overall_star_rating'],
      result['rating_count'],
      result['phone'] || "00000000",
      result['link'] || result['website'],
      "", 
      pick_categories(result['category'], result['category_list']),
      pick_categories(result['category'], result['category_list'], 'web'),
      get_current_open_time(result['hours']),
      get_photo(result['id']),
      "#{result['distance'] || ''}公尺"
    )
    return data
  end

  def set_text r, type='web'
    case type
    when 'web'
      text = "#{r.today_open_time}"
      text += "\n#{r.phone}"
      text += "\n#{r.street}"
    when 'line'
      text = "#{I18n.t('facebook.score')}：#{r.rating}#{I18n.t('common.score')}/#{r.rating_count}#{I18n.t('common.people')}" if r.rating.present?
      text += "\n#{r.category_list}"
      text += "\n#{r.today_open_time}"
      text = text[0, 60]
    when 'facebook'
      text = "#{I18n.t('facebook.score')}：#{r.rating}#{I18n.t('common.score')}/#{r.rating_count}#{I18n.t('common.people')}" if r.rating.present?
      text += "\n#{r.category_list}"
      text += "\n#{r.today_open_time}"
      text += "\n#{r.distance}"
      text = text[0, 80]
    end
    return text
  end

  def get_current_open_time hours=nil
    open_time = ''

    if hours.present? && hours.size > 0
      date = Time.now.strftime('%a').downcase
      hours = hours.reject {|key, value| !key.include?(date)}
      hours.to_a.each_with_index do |(key,value), index|
        open_time += "-" if key.include?('open') && index > 0
        open_time += "~" if key.include?('close')
        open_time += value.to_s
      end
    end

    if open_time.present?
      open_time
    else
      I18n.t('empty.no_hours')
    end
  end

  def get_photo id, width=450, height=450
    "https://graph.facebook.com/#{id}/picture?width=#{width}&height=#{height}"
  end

  def pick_categories category="", category_list=[], type='bot'
    categories = category_list.map { |c| c['name'] }
    categories = categories << category
    categories = (categories - REJECT_CATEGORY).uniq
    categories = categories.join(', ') if type == 'bot'
    return categories
  end
end