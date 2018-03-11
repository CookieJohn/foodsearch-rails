class BaseController < ApplicationController
  before_action :set_meta
  before_action :set_zoom, only: [:location]

  def index
  end

  def location
    @form = OpenStruct.new(
      lat: '',
      lng: '')
  end

  def selection
    @form = OpenStruct.new(
      search:   'restaurant',
      display:  '',
      card:     '',
      sort:     'score',
      open_now: true,
      lat:      params.dig(:form, :lat),
      lng:      params.dig(:form, :lng)
    )
  end

  def results
    fb_results = GraphApiService.new.search_places(
      params.dig(:form, :lat),
      params.dig(:form, :lng),
      size: 1000,
      mode: params.dig(:form, :sort),
      keyword: params.dig(:form, :search),
      open_now: params.dig(:form, :open_now))

    @card_type = params.dig(:form, :card)
    @restaurants = FormatService.new.web_format(fb_results)
  end

  def privacy
  end

  def set_locale
    if params[:locale].to_sym.presence_in(I18n.available_locales)
      session[:locale] = params[:locale]
      I18n.locale = session[:locale]
    end
    render json: {}, status: 200
  end
end
