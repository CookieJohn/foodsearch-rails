require 'koala'

class GraphApiService
	DEFAULT_SEARCH ||= 'restaurant'
	DEFAULT_DISTANCE ||= 500
	DEFAULT_MIN_SCORE ||= 3.9
	DEFAULT_FIELDS ||= 'location,name,overall_star_rating,rating_count,phone,link,price_range,category,category_list,hours'
	DEFAULT_RANDOM ||= true

	REJECT_PRICE ||= ['$$$','$$$$']

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

		location = "#{lat},#{lng}"
		facebook_results = graph.search(DEFAULT_SEARCH, type: :place,center: location, distance: max_distance, fields: DEFAULT_FIELDS, locale: I18n.locale.to_s)
		# 移除金額過高的搜尋結果
		# 移除連結不存在 的搜尋結果
		# 移除類別不包含 餐 的搜尋結果
		results = facebook_results.reject { |r| 
			REJECT_PRICE.include?(r['price_range'].to_s) ||
			!r['link'].to_s.present? ||
			(!r['category'].include?('餐') && !r['category_list'].any? {|c| c['name'].include?('餐') })  }
		results = results.select { |r| r['overall_star_rating'].to_f >= min_score }
		results = results.sort_by { |r| r['overall_star_rating'].to_f }.reverse

		results = random_type ? results.sample(5) : results.first(5)
	end

	def get_photo id
		"https://graph.facebook.com/#{id}/picture?type=large"
	end

	def get_current_open_time hours
		today = Time.now.wday
		date = case today
		when '1', 1
			'mon'
		when '2', 2
			'tue'
		when '3', 3
			'wed'
		when '4', 4
			'thu'
		when '5', 5
			'fri'
		when '6', 6
			'sat'
		when '7', 7
			'sun'
		end
		hours = hours.reject { |key, value| !key.include?(date) }
		open_time = ""
		hours.each_with_index do |(key,value), index|
			open_time += "-" if key.include?('open') && index > 0
			open_time += "~" if key.include?('close')
			open_time += value.to_s
		end
		return open_time
	end

end