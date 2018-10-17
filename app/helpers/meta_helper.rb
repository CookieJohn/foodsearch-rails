# frozen_string_literal: true

module MetaHelper
  def set_meta
    set_meta_tags 'Content-Type' => 'text/html; charset=UTF-8'
    set_meta_tags 'viewport' => 'width=device-width, initial-scale=1, maximum-scale=1'
    set_meta_tags title: 'FoodSearch',
                  description: '餐廳搜尋',
                  canonical: website_url
    set_meta_tags og: {
      title: 'FoodSearch',
      type: 'website',
      url: website_url,
      description: '餐廳搜尋',
      image: {
        _: site_image + ActionController::Base.helpers.image_url('fork_and_knife.jpg'),
        width: 400,
        height: 400
      }
    }
    set_meta_tags fb: { app_id: ENV['facebook_app_id'] }
    set_meta_tags twitter: {
      card: 'summary',
      site: website_url,
      title: 'FoodSearch',
      description: '餐廳搜尋',
      image: {
        _: site_image + ActionController::Base.helpers.image_url('fork_and_knife.jpg'),
        width: 400,
        height: 400
      }
    }
  end

  def website_url
    "https://#{request.host + request.fullpath}"
  end

  def site_image
    "#{request.protocol}#{request.host_with_port}"
  end
end
