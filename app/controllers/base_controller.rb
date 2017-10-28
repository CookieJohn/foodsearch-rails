class BaseController < ApplicationController
  before_action :set_meta, only: [:index, :search]
  before_action :get_lat_lng, only: [:refresh_locations]
  skip_before_action :verify_authenticity_token, only: [:refresh_locations]

  def index
  end

  def search
  end

  def refresh_locations
    fb_results = GraphApiService.new.search_places(@lat, @lng, size: 999, mode: @mode, keyword: @type)
    # if Rails.env.production?
    #    keywords = fb_results.map {|f| f['name']}
    #    google_results = GoogleMapService.new.search_places(@lat, @lng, nil, keywords)
    #  else
    #    google_results = nil
    #  end
    google_results = nil

    @location_data = FormatService.new.web_format(fb_results, google_results)
    respond_to do |format|
      format.js
    end
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
