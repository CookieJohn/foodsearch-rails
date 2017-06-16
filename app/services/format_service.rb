class FormatService
	REJECT_CATEGORY ||= I18n.t('settings.facebook.reject_category')

	attr_accessor :graph, :google, :common
  def initialize
    self.graph  ||= GraphApiService.new
    self.google ||= GoogleMapService.new
    self.common ||= CommonService.new
  end

	def web_format results=nil, google_results=nil
		columns = []

    category_lists = Category.pluck(:facebook_name)

    results.each do |result|
      id = result['id']
      name = result['name'][0, 40]
      lat = result['location']['latitude']
      lng = result['location']['longitude']
      street = result['location']['street'] || ""
      rating = result['overall_star_rating']
      rating_count = result['rating_count']
      phone = result.dig('phone').present? ? result['phone'].gsub('+886','0') : '無提供電話'
      link_url = result['link'] || result['website']
      category = result['category']
      category_list = result['category_list']
      hours = result['hours']

      description = category
      category_list.sample(2).each do |c|
        description += ", #{c['name']}" if c['name'] != category && !REJECT_CATEGORY.any? {|r| c['name'].include?(r) }
        new_category = Category.create!(facebook_id: c['id'], facebook_name: c['name']) if !category_lists.any? {|cl| cl.include?(c['name']) }
      end
      image_url = graph.get_photo(id,500,500)

      # actions = []
      # actions << set_action(I18n.t('button.official'), common.safe_url(link_url))
      # actions << set_action(I18n.t('button.location'), common.safe_url(google.get_map_link(lat, lng, name, street)))
      # actions << set_action(I18n.t('button.related_comment'), common.safe_url(google.get_google_search(name)))

      today_open_time = hours.present? ? graph.get_current_open_time(hours) : I18n.t('empty.no_hours')
      g_match = {'score' => 0.0, 'match_score' => 0.0}
      if google_results.present?
        google_results.each do |r|
          match_score = common.fuzzy_match(r['name'],name)
          if match_score >= I18n.t('google.match_score') && match_score > g_match['match_score']
            g_match['score'] = r['rating']
            g_match['match_score'] = match_score
          end
        end
      end

      # text = "#{I18n.t('facebook.score')}：#{rating}#{I18n.t('common.score')}/#{rating_count}#{I18n.t('common.people')}" if rating.present?
      # text += ", #{I18n.t('google.score')}：#{g_match['score'].to_f.round(2)}#{I18n.t('common.score')}" if g_match['score'].to_f > 2.0
      text = "\n#{description}"
      text += "\n#{today_open_time}"
      text += "\n#{phone}"

      google_score = (g_match['score'].to_f > 1) ? g_match['score'].to_f.round(2) : 0

      columns << {
        image_url: image_url,
        title: name,
        text: text,
        types: description,
        today_open_time: today_open_time,
        phone: phone,
        facebook_score: rating,
        facebook_score_count: rating_count,
        google_score: google_score,
        official: link_url,
  			location: google.get_map_link(lat, lng, name, street),
  			related_comment: google.get_google_search(name)
      }
    end
    return columns
	end
end