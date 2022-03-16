require "spec_helper"

module Incognia
  RSpec.describe APIResource do
    context ".from_hash" do
      subject { described_class.from_hash(foo: { bar: :val }, list: [:one, :two]) }

      it "returns an instance of klass" do
        expect(subject).to be_instance_of(described_class)
      end

      it "builds a loose object from a hash" do
        expect(subject.foo).to respond_to(:bar)
      end

      it "builds nested objects" do
        expect(subject.foo.bar).to eql(:val)
      end
    end
  end
end
