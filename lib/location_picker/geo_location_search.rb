require 'open-uri'

class LocationPicker::GeoLocationSearch
  include ::ActiveModel::Model
  attr_accessor :street, :house_number, :postal_code, :locality
  attr_reader :latitude, :longitude, :used_service

  def search
    search_nominatim
    search_google unless used_service.present?
    self
  end

  def to_h
    {
      result: success?,
      used_service: used_service,
      latitude: latitude,
      longitude: longitude,
    }
  end

  def success?
    used_service.present?
  end

  private

  def nominatim_response
    nominatim_urls = [
      { link: "http://nominatim.openstreetmap.org" },
      { link: "http://open.mapquestapi.com/nominatim/v1" }
    ]
    threads = []
    nominatim_urls.each_with_index do |object, url_index|
      threads << Thread.new(object[:link], url_index) do |link, my_index|
        nominatim_urls[my_index][:content] = open_nominatim(link) rescue nil
        threads.each_with_index do |thread, thread_index|
          thread.kill if my_index != thread_index
        end
      end
    end
    threads.each(&:join)
    JSON.parse(nominatim_urls.select { |url| url[:content].present? } .first[:content])
  end

  def search_nominatim
    response = nominatim_response
    if response.length > 0
      @latitude = response.first["lat"]
      @longitude = response.first["lon"]
      @used_service = "Nominatim"
    end
  end

  def open_nominatim(link)
    open("#{link}/#{url_nominatim}").read
  end

  def open(url)
    super(url, read_timeout: 5)
  end

  def url_nominatim
    params = {
      format: "json",
      q: "#{one_line_address}"
    }
    "search?#{params.to_query}"
  end

  def search_google
    response = JSON.parse(open(url_google).read) rescue { "results" => [] }
    if response["results"].length > 0
      location = response["results"].first["geometry"]["location"]
      @latitude = location["lat"]
      @longitude = location["lng"]
      return @used_service = "Google"
    end
    false
  end

  def one_line_address
    "#{street} #{house_number}, #{postal_code} #{locality}"
  end

  def url_google
    params = {
      sensor: "false",
      address: "#{one_line_address}"
    }
    "http://maps.googleapis.com/maps/api/geocode/json?#{params.to_query}"
  end
end