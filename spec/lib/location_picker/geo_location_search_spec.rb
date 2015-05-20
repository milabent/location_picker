require 'rails_helper'

RSpec.describe LocationPicker::GeoLocationSearch , type: :model do
  let!(:good_search) { 
    described_class.new(
      street: "August-Bebel-Straße",
      house_number: "4",
      postal_code: "18055",
      locality: "Rostock"
    )
  }
  let!(:bad_search) { 
    search = good_search.clone
    search.street = 'Fakestreet'
    search.locality = 'Fakecity'
    search
  }

  describe 'nominatim' do
    it "url" do
      expect(good_search.send(:url_nominatim)).to eq "search?format=json&q=August-Bebel-Stra%C3%9Fe+4%2C+18055+Rostock"
    end

    it "searchs" do
      VCR.use_cassette('geo-position-nominatim') do
        allow(good_search).to receive(:open_nominatim).with(/open.mapquestapi.com/) { sleep 1 }
        allow(good_search).to receive(:open_nominatim).with(/nominatim.openstreetmap.org/).and_call_original
        allow(bad_search).to receive(:open_nominatim).with(/open.mapquestapi.com/) { sleep 1 }
        allow(bad_search).to receive(:open_nominatim).with(/nominatim.openstreetmap.org/).and_call_original

        good_search.send(:search_nominatim)
        expect(good_search.success?).to eq true

        bad_search.send(:search_nominatim)
        expect(bad_search.success?).to eq false
      end
    end

    describe "nominatim_response" do
      let(:mapquest) { { "result" => "mapquest" } }
      let(:nominatim) { { "result" => "nominatim" } }
      context "mapquest is faster" do
        it "responses" do
          allow(good_search).to receive(:open_nominatim).with("http://nominatim.openstreetmap.org") do
            sleep 1
            nominatim.to_json
          end
          allow(good_search).to receive(:open_nominatim).with("http://open.mapquestapi.com/nominatim/v1") do
            mapquest.to_json
          end
          expect(good_search.send(:nominatim_response)).to eq mapquest
        end
      end

      context "nominatim is faster" do
        it "responses" do
          allow(good_search).to receive(:open_nominatim).with("http://nominatim.openstreetmap.org") do
            nominatim.to_json
          end
          allow(good_search).to receive(:open_nominatim).with("http://open.mapquestapi.com/nominatim/v1") do
            sleep 1
            mapquest.to_json
          end
          expect(good_search.send(:nominatim_response)).to eq nominatim
        end
      end
    end
  end

  describe 'google' do
    it "url" do
      expect(good_search.send(:url_google)).to eq "http://maps.googleapis.com/maps/api/geocode/json?address=August-Bebel-Stra%C3%9Fe+4%2C+18055+Rostock&sensor=false"
    end

    it "searchs" do
      VCR.use_cassette('geo-position-google') do
        good_search.send(:search_google)
        expect(good_search.success?).to eq true

        bad_search.send(:search_google)
        expect(bad_search.success?).to eq false
      end
    end
  end
end