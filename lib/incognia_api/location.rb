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
        hash = {
          latitude: latitude,
          longitude: longitude
        }
        hash[:collected_at] = collected_at.iso8601 if collected_at
      
        {
          location: hash
        }
      end
      
    private

    def parse_timestamp(timestamp)
        return nil unless timestamp
        Time.iso8601(timestamp)
    rescue ArgumentError
        raise ArgumentError, "Location 'collected_at' attribute not in RFC3339 format: #{timestamp}"
    end
    end
end