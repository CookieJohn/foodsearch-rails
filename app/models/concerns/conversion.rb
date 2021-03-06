# frozen_string_literal: true

module Conversion
  def reorganization(result, type, index = nil)
    result = OpenStruct.new(
      index: index,
      id: result['id'],
      name: result['name'][0, 40],
      lat: result['location']['latitude'],
      lng: result['location']['longitude'],
      street: result['location']['street'] || I18n.t('empty.address'),
      rating: result['overall_star_rating'],
      rating_count: result['rating_count'],
      google_score: nil,
      phone: result['phone'] || I18n.t('empty.phone'),
      link_url: result['link'] || result['website'],
      description: nil,
      category_list: pick_categories(result['category'], result['category_list']),
      category_list_web: pick_categories(result['category'], result['category_list'], 'web'),
      business_hours: get_current_open_time(result['hours']),
      open_now: result['open_now'],
      image_url: result['picture']['data']['url'],
      distance: (result['distance'] || '').to_s,
      actions: nil
    )
    result.description = set_description(result, type)
    result
  end

  def set_description(res, type = 'web')
    max_word = case type
               when 'line'     then 60
               when 'facebook' then 80
               end

    return unless max_word

    "#{I18n.t('facebook.score')}：#{res.rating}#{I18n.t('common.score')}/" \
     "#{res.rating_count}#{I18n.t('common.people')}\n" \
     "#{res.category_list}\n#{res.business_hours}\n" \
     "#{res.distance}#{I18n.t('label.meter')}"[0, max_word]
  end

  def get_current_open_time(fb_open_hours = nil)
    open_time = ''
    if fb_open_hours.to_a.any?
      date = Time.zone.now.strftime('%a').downcase # ex: fri
      fb_open_hours.to_a.each do |(key, value)|
        next unless key.include?(date)

        if key.include?('open') && open_time.present? then ", #{value}"
        elsif key.include?('close') then "~#{value}"
        else value
        end
      end
    end

    open_time.present? ? open_time : I18n.t('empty.business_hours')
  end

  def pick_categories(category = '', category_list = [], type = 'bot')
    categories = category_list.map { |c| c['name'] }
    categories = categories << category
    categories = (categories - BaseService::REJECT_CATEGORY).uniq
    categories = categories.join(', ') if type == 'bot'
    categories
  end
end
