class LocationPicker::LocationsController < ApplicationController
  def create
    geo_location_search = LocationPicker::GeoLocationSearch .new(geo_location_search_params)
    geo_location_search.search
    render json: geo_location_search.to_h
  end

  protected

  def geo_location_search_params
    params.require(:geo_location_search)
  end
end
