require "spec_helper"

module Incognia
  RSpec.describe Address do
    let(:locale) { "en-US" }
    let(:country_name) { "United States of America" }
    let(:country_code) { "US" }
    let(:state) { "NY" }
    let(:city) { "New York City" }
    let(:borough) { "Manhattan" }
    let(:neighborhood) { "Midtown" }
    let(:street) { "W 34th St." }
    let(:number) { "20" }
    let(:complements) { "Floor 2" }
    let(:postal_code) { "10001" }
    let(:structured_format) do
      {
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
       }
    end
    let(:line_format) do
      "#{number} #{street} #{city} #{state} #{postal_code}"
    end
    let(:coordinates_format) { { lat: 40.748360070638, lng: -73.985097204837 } }

    let(:line_address) { described_class.new(line: line_format) }
    let(:coordinates_address) do
      described_class.new(coordinates: coordinates_format)
    end
    let(:structured_address) do
      described_class.new(structured: structured_format)
    end
    let(:complete_address) do
      described_class.new(
        line: line_format,
        coordinates: coordinates_format,
        structured: structured_format
      )
    end

    it "requires one of line, coordinates or structured format" do
      expect { described_class.new }.to raise_error ArgumentError
    end

    context "#to_hash" do
      it "provides #to_hash merging addresses field" do
        expect(
          described_class.new(
            line: line_format,
            coordinates: coordinates_format,
            structured: structured_format
          ).to_hash.keys
        ).to_not include(
          address_line: line_format,
          address_coordinates: coordinates_format,
          structured_address: structured_format
        )
      end

      it "omits empty address formats" do
        expect(
          described_class.new(
            line: nil,
            coordinates: {},
            structured: structured_format
          ).to_hash.keys
        ).to_not include(:line, :coordinates)
      end
    end

    describe Address::Line do
      subject { described_class.new(line_format) }

      it "provides #to_hash with the API format" do
        expect(subject.to_hash).to include(address_line: line_format)
      end
    end

    describe Address::Coordinates do
      subject { described_class.new(**coordinates_format) }

      it "provides #to_hash with the API format" do
        expect(subject.to_hash).to eql(address_coordinates: coordinates_format)
      end
    end

    describe Address::Structured do
      subject { described_class.new(**structured_format) }

      it "provides #to_hash with the API format" do
        expect(
          described_class.new(**structured_format).to_hash
        ).to eql(structured_address: structured_format)
      end

      it "omits nil values" do
        expect(
          described_class.new(street: "foo", city: nil).to_hash
        ).to eql(structured_address: { street: "foo" })
      end
    end
  end
end
