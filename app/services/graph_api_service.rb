require 'koala'

class GraphApiService < BaseService
  DEFAULT_SEARCH ||= 'restaurant'
  DEFAULT_DISTANCE ||= 500
  DEFAULT_MIN_SCORE ||= 3.8
  DEFAULT_RANDOM ||= true
  DEFAULT_OPEN ||= false
  DEFAULT_FIELDS ||= 'location,name,overall_star_rating,rating_count,
                            phone,link,price_range,category,category_list,
                            hours,website,is_permanently_closed'

  attr_accessor :graph
  def initialize
    oauth_access_token = Koala::Facebook::OAuth.new.get_app_access_token
    self.graph = Koala::Facebook::API.new(oauth_access_token)
  end

  def search_places lat, lng, options={}
    limit = 100
    user = options[:user] || nil
    size = options[:size] || 5
    mode = options[:mode] || nil
    keyword = options[:keyword] || 'restaurant'

    position = "#{lat},#{lng}"
    max_distance = user.try(:max_distance) || DEFAULT_DISTANCE
    min_score = user.try(:min_score) || DEFAULT_MIN_SCORE
    random_type = user.try(:random_type) || DEFAULT_RANDOM
    open_now = user.try(:open_now) || DEFAULT_OPEN

    facebook_results = graph.search(keyword, type: :place, center: position,
                                    distance: max_distance, locale: I18n.locale.to_s, limit: limit,
                                    matched_categories: "FOOD_BEVERAGE", fields: DEFAULT_FIELDS)
    # 移除連結不存在 的搜尋結果
    # 移除類別不包含 餐 的搜尋結果
    # 移除評分低於設定數字的搜尋結果

    results = facebook_results.reject { |r|
      r['category_list'].any? {|c| REJECT_CATEGORY.any?{|n| c['name'] == n } } ||
        r['is_permanently_closed'] == true ||
        (r['overall_star_rating'].to_f >= 1 && r['overall_star_rating'].to_f <= min_score) }
    # 判斷目前是否營業中
    results = results.reject { |r| check_open_now(r['hours']) == false } if open_now

    # 計算距離
    results = results.each { |r| r['distance'] = (count_distance([lat, lng], [r['location']['latitude'], r['location']['longitude']])).to_i }
    results = results.reject { |r| r['distance'] > max_distance }

    results = case mode
              when 'score'
                results.sort_by { |r| [r['overall_star_rating'].to_f, r['rating_count'].to_i] }.reverse
              when 'distance'
                results = results.sort_by { |r| r['distance'] }
              else
                results = random_type ? results.sample(size) : results.first(size)
              end
  end

  def check_open_now hours=nil
    open_now = false
    if hours.present?
      date = Time.now.strftime('%a').downcase
      hours = hours.reject {|key, value| !key.include?(date)}
      if hours.size > 0
        open_time_array = []
        (1..3).each do |i|
          temp_array = []
          hours.each do |key, value|
            temp_array << value if key.include?("_#{i}_")
          end
          open_time_array << temp_array if temp_array.size > 0
        end
        current_time = Time.now.strftime('%R')
        open_time_array.each do |time|
          open_now = true if current_time.between?(time.first, time.last)
        end
      end
    else
      open_now = true
    end
    return open_now
  end
end
