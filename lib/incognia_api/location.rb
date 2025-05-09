require 'time'

module Incognia
  class Location
    attr_reader :latitude, :longitude, :collected_at

    def initialize(latitude:, longitude:, collected_at: nil)
        @latitude = latitude
        @longitude = longitude
        @collected_at = collected_at
    end

    def to_hash
      location = {
        latitude: latitude,
        longitude: longitude,
        collected_at: collected_at.respond_to?(:to_datetime) ? collected_at.to_datetime.rfc3339 : collected_at,
      }.compact

      location
    end
  end
end