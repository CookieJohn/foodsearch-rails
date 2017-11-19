require 'rails_helper'

RSpec.describe BaseController, type: :request do
  describe "request" do

    context "index" do
      it "success" do
        get root_url
        expect(response).to have_http_status(200)
      end
    end

    context "search" do
      it "success" do
        get location_url
        expect(response).to have_http_status(200)
      end
    end

    context "ajax" do
      let(:lat) { 25.084555 }
      let(:lng) { 121.456564 }
      let(:search_type) { "" }

      it "success" do
        VCR.use_cassette('facebook/search', record: :new_episodes) do
          get results_url, params: { form: { lat: lat, lng: lng, search_type: search_type } }, xhr: true
          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
