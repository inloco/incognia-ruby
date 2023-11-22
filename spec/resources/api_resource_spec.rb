require "spec_helper"

module Incognia
  RSpec.describe APIResource do
    context ".from_hash" do
      subject(:from_hash) { described_class.from_hash(foo: { bar: :val }, list: [:one, :two]) }

      it "returns an instance of klass" do
        expect(from_hash).to be_instance_of(described_class)
      end

      it "builds a loose object from a hash" do
        expect(from_hash.foo).to respond_to(:bar)
      end

      it "builds nested objects" do
        expect(from_hash.foo.bar).to eql(:val)
      end

      context "when calling an inexistent attribute" do
        it "returns nil" do
          expect(from_hash.inexistent).to be_nil
        end
      end
    end
  end
end
