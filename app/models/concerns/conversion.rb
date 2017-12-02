module Conversion
  def format(result, index = nil)
    OpenStruct.new(
      index: index,
      id: result['id'],
      name: result['name'][0, 40],
      lat: result['location']['latitude'],
      lng: result['location']['longitude'],
      street: result['location']['street'] || I18n.t('empty.address'),
      rating: result['overall_star_rating'],
      rating_count: result['rating_count'],
      google_score: '',
      phone: result['phone'] || I18n.t('empty.phone'),
      link_url:
      result['link'] || result['website'],
      text: '',
      category_list: pick_categories(
        result['category'],
        result['category_list']
      ),
      category_list_web: pick_categories(
        result['category'],
        result['category_list'],
        'web'
      ),
      business_hours: get_current_open_time(result['hours']),
      open_now: result['open_now'],
      image_url: get_photo(result['id']),
      distance: "#{result['distance'] || ''}",
      actions: ''
    )
  end

  def set_text(r, type = 'web')
    case type
    when 'web'
      %Q(#{r.business_hours}
       #{r.phone}
       #{r.street}
      )
    when 'line'
      %Q(#{I18n.t('facebook.score')}：#{r.rating}#{I18n.t('common.score')}/#{r.rating_count}#{I18n.t('common.people')}
      #{r.category_list}\n#{r.business_hours}
      #{r.distance}#{I18n.t('label.meter')}
      )[0, 60]
    when 'facebook'
      %Q(#{I18n.t('facebook.score')}：#{r.rating}#{I18n.t('common.score')}/#{r.rating_count}#{I18n.t('common.people')}
      #{r.category_list}\n#{r.business_hours}
      #{r.distance}#{I18n.t('label.meter')}
      )[0, 80]
    end
  end

  def get_current_open_time(hours = nil)
    open_time = ''
    if hours.present? && hours.size.positive?
      open_time = ''
      date = Time.zone.now.strftime('%a').downcase
      hours = hours.select { |key, value| key.include?(date) }
      hours.to_a.each_with_index do |(key, value), index|
        open_time += '-' if key.include?('open') && index.positive?
        open_time += '~' if key.include?('close')
        open_time += value.to_s
      end
    end

    open_time.present? ? open_time : I18n.t('empty.business_hours')
  end

  def get_photo(id, width = 450, height = 450)
    "https://graph.facebook.com/#{id}/picture?width=#{width}&height=#{height}"
  end

  def pick_categories(category = '', category_list = [], type = 'bot')
    categories = category_list.map { |c| c['name'] }
    categories = categories << category
    categories = (categories - BaseService::REJECT_CATEGORY).uniq
    categories = categories.join(', ') if type == 'bot'
    categories
  end
end
