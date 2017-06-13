module MetaHelper
	def set_meta
		set_meta_tags "noindex" => "robots"
    set_meta_tags "noindex" => "googlebot"
		set_meta_tags "Content-Type" => "text/html; charset=UTF-8"
		set_meta_tags "viewport" => "width=device-width, initial-scale=1, maximum-scale=1"
		set_meta_tags title: 'FoodSearch',
			description: "餐廳搜尋",
			canonical: "https://#{request.host+request.fullpath}"
	end
end