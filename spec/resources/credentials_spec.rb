require "spec_helper"

module Incognia
  RSpec.describe Credentials do
    context "#stale?" do
      subject do
        described_class.from_hash({ generated_at: Time.now, expires_in: 60 })
      end

      it "returns true when >10s ahead expiration time" do
        subject
        Timecop.travel(Time.now + 50) { expect(subject).to be_stale }
      end

      it "returns false when refresh time hasn't passed" do
        expect(subject).to_not be_stale
      end
    end
  end
end
