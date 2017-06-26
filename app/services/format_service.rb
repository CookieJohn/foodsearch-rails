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

    category_lists = Category.pluck(:id)

    results.each do |result|
      id = result['id']
      name = result['name']
      lat = result['location']['latitude']
      lng = result['location']['longitude']
      street = result['location']['street'] || "無提供地址"
      rating = result['overall_star_rating']
      rating_count = result['rating_count']
      phone = result.dig('phone').present? ? result['phone'].gsub('+886','0') : '無提供電話'
      link_url = result['link'] || result['website']
      category = result['category']
      category_list = result['category_list']
      hours = result['hours']
      distance = result['distance'].present? ? "#{(result['distance']*1000).to_i}公尺" : ''

      types = [category]
      category_list.first(2).each do |c|
        types << c['name'] if c['name'] != category && !REJECT_CATEGORY.any? {|r| c['name'].include?(r) }
        new_category = Category.create!(facebook_id: c['id'], facebook_name: c['name']) if !category_lists.any? {|cl| cl.include?(c['id']) }
      end
      image_url = graph.get_photo(id,500,500)

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

      text = "#{today_open_time}"
      text += "\n#{phone}"
      text += "\n#{street}"

      open_time = today_open_time.present? ? today_open_time : '無提供時間'

      google_score = (g_match['score'].to_f > 0.1) ? " #{g_match['score'].to_f.round(2)}分" : ' 無'

      columns << {
        image_url: image_url,
        title: name,
        open_time: open_time,
        phone: phone,
        street: street,
        text: text,
        types: types,
        facebook_score: rating,
        facebook_score_count: rating_count,
        google_score: google_score,
        official: link_url,
  			location: google.get_map_link(lat, lng, name, street),
  			related_comment: google.get_google_search(name),
        distance: distance
      }
    end
    return columns
	end
end