# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BaseController, type: :request do
  context 'index' do
    it 'success' do
      get root_url
      expect(response).to have_http_status(200)
    end
  end

  context 'get location' do
    it 'success' do
      get location_url
      expect(response).to have_http_status(200)
    end
  end

  context 'get selection' do
    it 'success' do
      get selection_url
      expect(response).to have_http_status(200)
    end
  end

  context 'get restaurants' do
    let(:lat) { 25.084555 }
    let(:lng) { 121.456564 }
    let(:search_type) { '' }

    it 'success' do
      VCR.use_cassette('facebook/search', record: :new_episodes) do
        get results_url, params: { form: { lat: lat, lng: lng, search_type: search_type } }
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'privacy' do
    it 'success' do
      get privacy_url
      expect(response).to have_http_status(200)
    end
  end
end
