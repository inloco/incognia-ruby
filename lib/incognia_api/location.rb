require 'time'

module Incognia
  class Location
    attr_reader :latitude, :longitude, :collected_at

    def initialize(latitude:, longitude:, collected_at: nil)
        @latitude = latitude
        @longitude = longitude
        @collected_at = parse_timestamp(collected_at)
    end

    def to_hash
      location = {
        latitude: latitude,
        longitude: longitude,
        collected_at:  collected_at&.iso8601
      }.compact

      location
    end
      
    private

    def parse_timestamp(timestamp)
      return nil unless timestamp
    
      begin
        Time.iso8601(timestamp)
      rescue ArgumentError
        raise ArgumentError, "Location 'collected_at' attribute not in RFC3339 format: #{timestamp}"
      end
    end    
  end
end