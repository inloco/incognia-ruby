require "ostruct"

module Incognia
  class Address
    attr_reader :line, :coordinates, :structured

    class Line
      def initialize(address)
        @address = address
      end

      def to_hash
        { address_line: @address }
      end
    end

    class Coordinates
      def initialize(lat:, lng:)
        @lat, @lng = lat, lng
      end

      def to_hash
        { address_coordinates: { lat: @lat, lng: @lng } }
      end
    end

    class Structured
      attr_reader :locale, :country_name, :country_code, :state, :city, :borough,
        :neighborhood, :state, :city, :borough, :neighborhood, :postal_code,
        :street, :number, :complements

      def initialize(locale: nil, country_name: nil, country_code: nil, \
                     state: nil, city: nil, borough: nil, neighborhood: nil, \
                     postal_code: nil, street: nil, number: nil, complements: nil)

        @locale = locale
        @country_name = country_name
        @country_code = country_code
        @state = state
        @city = city
        @borough = borough
        @neighborhood = neighborhood
        @postal_code = postal_code
        @street = street
        @number = number
        @complements = complements
      end

      def to_hash
        {
          structured_address: {
            locale: locale,
            country_name: country_name,
            country_code: country_code,
            state: state,
            city: city,
            borough: borough,
            neighborhood: neighborhood,
            street: street,
            number: number,
            complements: complements,
            postal_code: postal_code
          }.select { |_,v| !v.nil? }
        }
      end
    end

    FORMATS = [:line, :coordinates, :structured].freeze

    def initialize(line: nil, coordinates: {}, structured: {})
      coordinates = Util.symbolize_names(coordinates)
      structured = Util.symbolize_names(structured)

      if line.nil? && coordinates.empty? && structured.empty?
        raise ArgumentError.new(
          "missing keyword: should be one of #{FORMATS.join(', ')}"
        )
      end

      @line = build_line(line)
      @coordinates = build_coordinates(coordinates)
      @structured = build_structured(structured)
    end

    def to_hash
      hash = {}
      hash.merge!(@line.to_hash)
      hash.merge!(@coordinates.to_hash)
      hash.merge!(@structured.to_hash)
      hash
    end

    protected

    def build_coordinates(hash)
      hash.empty? ? hash : Coordinates.new(**hash)
    end

    def build_line(raw_line = nil)
      raw_line ? Line.new(raw_line) : {}
    end

    def build_structured(hash)
      hash.empty? ? hash : Structured.new(**hash)
    end

  end
end
