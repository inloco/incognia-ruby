# spec/incognia/person_id_spec.rb
require "spec_helper"

module Incognia
  RSpec.describe PersonId do
    let(:type)  { "cpf" }
    let(:value) { "12345678901" }

    subject(:person_id) { described_class.new(type: type, value: value) }

    it "requires type and value" do
      expect { described_class.new }.to raise_error(ArgumentError)
      expect { described_class.new(type: type) }.to raise_error(ArgumentError)
      expect { described_class.new(value: value) }.to raise_error(ArgumentError)
    end

    describe "#to_hash" do
      it "returns the API format" do
        expect(person_id.to_hash).to eql(type: type, value: value)
      end
    end

    describe "readers" do
      it "exposes #type and #value" do
        expect(person_id.type).to  eq(type)
        expect(person_id.value).to eq(value)
      end
    end
  end
end
