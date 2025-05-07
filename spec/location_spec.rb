require "spec_helper"

module Incognia
  RSpec.describe Location do
    let(:latitude) { 12.123 }
    let(:longitude) { -7.123 }
    let(:collected_at) { "2025-04-23T12:12:12-03:00" }
    let(:simple_format) do
      {
        latitude: latitude,
        longitude: longitude,
      }
    end
    let(:complete_format) do
      {
        latitude: latitude,
        longitude: longitude,
        collected_at: collected_at,
      }
    end
    let(:simple_location) do
      described_class.new(latitude: latitude, longitude: longitude)
    end
    let(:complete_location) do
      described_class.new(latitude: latitude, longitude: longitude, collected_at: collected_at)
    end

    INVALID_TIMESTAMPS = [
        "2025-04-23T12:12:12-3:00",
        "2025-04-23T12:12:12-30:00",
        "2025-04-23T12:12-03:00",
        "2025-04-23",
        "20250423",
        "2024 Mar 03 05:12:41.211 PDT",
        "Jan 21 18:20:11 +0000 2024",
        "19/Apr/2023:06:36:15 -0700",
        "Dec 2, 2023 2:39:58 AM",
        "Jun 09 2023 15:28:14"
    ].freeze

    let(:valid_utc_timestamp) { "2025-04-23T12:12:12Z"}

    it "does not accept empty parameters" do
      expect { described_class.new }.to raise_error ArgumentError
    end

    it "does not accept just a latitude parameter" do
      expect { described_class.new(latitude:latitude) }.to raise_error ArgumentError
    end

    it "does not accept just a longitude parameter" do
      expect { described_class.new(longitude:longitude) }.to raise_error ArgumentError
    end

    INVALID_TIMESTAMPS.each do |invalid_ts|
      it "raises ArgumentError for invalid collected_at: '#{invalid_ts}'" do
        expect {
          described_class.new(latitude: latitude, longitude: longitude, collected_at: invalid_ts)
        }.to raise_error(ArgumentError)
      end
    end

    it "accepts a valid UTC timestamp" do
      utc_timestamp = "2025-04-23T12:12:12Z"
      location = described_class.new(latitude: latitude, longitude: longitude, collected_at: utc_timestamp)
    
      expect(location.to_hash).to eql({
        latitude: latitude,
        longitude: longitude,
        collected_at: utc_timestamp
      })
    end

    it "omits nil values" do
      expect(
        described_class.new(latitude: latitude, longitude: longitude, collected_at: nil).to_hash
      ).to eql(simple_format)
    end

    it "provides #to_hash with the API format (simple)" do
      expect(simple_location.to_hash).to eql(simple_format)
    end

    it "provides #to_hash with the API format (complete)" do
      expect(complete_location.to_hash).to eql(complete_format)
    end
  end
end
