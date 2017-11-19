class BaseController < ApplicationController
  before_action :set_meta#, only: [:index, :search]
  before_action :get_lat_lng, only: [:selection]

  def index
  end

  def location
    @zoom = if browser.mobile?
              15
            else
              16
            end

    @form = OpenStruct.new(
      lat: '',
      lng: '')
  end

  def selection
    @form = OpenStruct.new(
      search: 'restaurant',
      display: '',
      sort: 'score',
      open_now: true,
      lat: params.dig(:form, :lat),
      lng: params.dig(:form, :lng))
  end

  def results
    @mode = params.dig(:form, :sort)
    @type = params.dig(:form, :search)
    @lat = params.dig(:form, :lat)
    @lng = params.dig(:form, :lng)
    @open_now = params.dig(:form, :open_now)
    fb_results = GraphApiService.new.search_places(
      @lat,
      @lng,
      size: 999,
      mode: @mode,
      keyword: @type,
      open_now: @open_now)
    @restaurants = FormatService.new.web_format(fb_results)
  end

  def privacy
  end

  private

  def get_lat_lng
    @lat = params['lat']
    @lng = params['lng']
    @mode = cookies['mode'].present? ? cookies['mode'] : 'score'
    @type = cookies['type'].present? ? cookies['type'] : 'restaurant'
    @type = params.dig('search_type').present? ? params.dig('search_type') : @type
  end
end
