require "spec_helper"
require "date"

module Incognia
  RSpec.describe Location do
    let(:latitude) { 12.123 }
    let(:longitude) { -7.123 }
    let(:collected_at) { "2025-04-23T12:12:12-03:00" }

    let(:simple_location) do
      described_class.new(latitude: latitude, longitude: longitude)
    end

    let(:complete_location) do
      described_class.new(latitude: latitude, longitude: longitude, collected_at: collected_at)
    end

    describe "#to_hash" do
      it "omits nil values" do
        expected_hash = {
          latitude: latitude,
          longitude: longitude,
        }

        expect(
          described_class.new(latitude: latitude, longitude: longitude, collected_at: nil).to_hash
        ).to match(expected_hash)
      end

      context "when the Location object does NOT have a collected_at field" do
        it "returns a hash with latitude and longitude" do
          expected_hash = {
            latitude: latitude,
            longitude: longitude,
          }
    
          expect(simple_location.to_hash).to match(expected_hash)
        end
      end
    
      context "when the Location object has a collected_at field" do
        it "returns a hash with latitude, longitude and timestamp" do
          expected_hash = {
            latitude: latitude,
            longitude: longitude,
            collected_at: collected_at,
          }
    
          expect(complete_location.to_hash).to match(expected_hash)
        end
      end

      shared_examples "collected_at normalization" do |klass_name, value_proc|
        context "when receiving a #{klass_name} object in collected_at field" do
          let(:collected_at) { instance_exec(&value_proc) }

          it "returns a hash with collected_at in RFC3339 format" do
            expected_hash = {
              latitude: latitude,
              longitude: longitude,
              collected_at: collected_at.to_datetime.rfc3339,
            }

            location = described_class.new(latitude: latitude, longitude: longitude, collected_at: collected_at)
            expect(location.to_hash).to match(expected_hash)
          end
        end
      end

      include_examples "collected_at normalization", "Date", -> { Date.parse("2025-04-23T12:12:12-03:00") }
      include_examples "collected_at normalization", "Time", -> { Time.new(2025, 4, 23, 12, 12, 12, "-03:00") }
      include_examples "collected_at normalization", "DateTime", -> { DateTime.parse("2025-04-23T12:12:12-03:00") }
    end
  end
end
