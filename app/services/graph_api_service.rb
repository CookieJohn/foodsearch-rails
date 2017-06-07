require 'koala'

class GraphApiService
	DEFAULT_SEARCH ||= I18n.t('settings.facebook.search_type')
	DEFAULT_DISTANCE ||= I18n.t('settings.facebook.distance')
	DEFAULT_MIN_SCORE ||= I18n.t('settings.facebook.score')
	DEFAULT_FIELDS ||= I18n.t('settings.facebook.fields')
	DEFAULT_RANDOM ||= I18n.t('settings.facebook.random')

	REJECT_PRICE ||= I18n.t('settings.facebook.reject_price')
	REJECT_NAME ||= I18n.t('settings.facebook.reject_name')

	attr_accessor :graph
	def initialize
		@oauth = Koala::Facebook::OAuth.new
		oauth_access_token = @oauth.get_app_access_token
		self.graph = Koala::Facebook::API.new(oauth_access_token)
	end

	def search_places lat, lng, user=nil
			
		max_distance = user.present? ? user.max_distance : DEFAULT_DISTANCE
		min_score = user.present? ? user.min_score : DEFAULT_MIN_SCORE
		random_type = user.present? ? user.random_type : DEFAULT_RANDOM

		facebook_results = graph.search(DEFAULT_SEARCH, type: :place,center: "#{lat},#{lng}", distance: max_distance, fields: DEFAULT_FIELDS, locale: I18n.locale.to_s)
		# 移除金額過高的搜尋結果
		# 移除連結不存在 的搜尋結果
		# 移除類別不包含 餐 的搜尋結果
		# 移除評分低於設定數字的搜尋結果
		results = facebook_results.reject { |r| 
			REJECT_PRICE.include?(r['price_range'].to_s) ||
			REJECT_NAME.any? {|n| r['name'].include?(n)} ||
			!r['link'].to_s.present? ||
			(!r['category'].include?(I18n.t('common.meal')) && !r['category_list'].any? {|c| c['name'].include?(I18n.t('common.meal')) }) ||
			r['overall_star_rating'].to_f < min_score }
		results = results.sort_by { |r| r['overall_star_rating'].to_f }.reverse

		results = random_type ? results.sample(5) : results.first(5)
	end

	def get_photo id
		"https://graph.facebook.com/#{id}/picture??width=450&height=300"
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