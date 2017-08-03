require 'koala'

class GraphApiService
	DEFAULT_SEARCH ||= I18n.t('settings.facebook.search_type')
	DEFAULT_DISTANCE ||= I18n.t('settings.facebook.distance')
	DEFAULT_MIN_SCORE ||= I18n.t('settings.facebook.score')
	DEFAULT_FIELDS ||= I18n.t('settings.facebook.fields')
	DEFAULT_RANDOM ||= I18n.t('settings.facebook.random')

	REJECT_PRICE ||= I18n.t('settings.facebook.reject_price')
	REJECT_NAME ||= I18n.t('settings.facebook.reject_name')
	REJECT_CATEGORY ||= I18n.t('settings.facebook.reject_category')

	attr_accessor :graph, :common
	def initialize
		oauth_access_token = Koala::Facebook::OAuth.new.get_app_access_token
		self.graph = Koala::Facebook::API.new(oauth_access_token)
		self.common ||= CommonService.new
	end

	def search_places lat, lng, user=nil, size=5, mode=nil, type=nil

		limit = 100

		type = type.present? ? type : 'restaurant'
		
		position = "#{lat},#{lng}"
		max_distance = user.present? ? user.max_distance : DEFAULT_DISTANCE
		min_score = user.present? ? user.min_score : DEFAULT_MIN_SCORE
		random_type = user.present? ? user.random_type : DEFAULT_RANDOM

		facebook_results = graph.search(type, type: :place,center: position, distance: max_distance, limit: limit, fields: DEFAULT_FIELDS, locale: I18n.locale.to_s)
		# 移除金額過高的搜尋結果
		# 移除連結不存在 的搜尋結果
		# 移除類別不包含 餐 的搜尋結果
		# 移除評分低於設定數字的搜尋結果

		results = facebook_results.reject { |r| 
			REJECT_PRICE.include?(r['price_range'].to_s) ||
			REJECT_NAME.any? {|n| r['name'].include?(n)} ||
			r['category_list'].any? {|c| REJECT_CATEGORY.any?{|n| c['name'].include?(n)} } ||
			r['overall_star_rating'].to_f <= min_score }
		# 計算距離
		if mode.present?
			results = results.each { |r| r['distance'] = (common.count_distance([lat, lng], [r['location']['latitude'], r['location']['longitude']])*1000).to_i }
			results = results.reject { |r| r['distance'] > max_distance }
		end
		results = case mode
		when 'score'
			results.sort_by { |r| [r['overall_star_rating'].to_f, r['rating_count'].to_i] }.reverse
		when 'distance'
			results = results.sort_by { |r| r['distance'] }
		else
			results = random_type ? results.sample(size) : results.first(size)
			results = results.each { |r| r['distance'] = (common.count_distance([lat, lng], [r['location']['latitude'], r['location']['longitude']])*1000).to_i }
			results = results.reject { |r| r['distance'] > max_distance }
		end
	end

	def get_photo id, width=450, height=450
		"https://graph.facebook.com/#{id}/picture?width=#{width}&height=#{height}"
	end

	def get_current_open_time hours
		date = Time.now.strftime('%a').downcase
		hours = hours.reject {|key, value| !key.include?(date)}
		open_time = ''
		hours.each_with_index do |(key,value), index|
			open_time += "-" if key.include?('open') && index > 0
			open_time += "~" if key.include?('close')
			open_time += value.to_s
		end
		return open_time
	end
end