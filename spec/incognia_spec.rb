# frozen_string_literal: true

module Incognia
  RSpec.describe Incognia::Api do
    subject do
      Api.new(client_id: 'client_id', client_secret: 'client_secret')
    end

    describe "#register_signup" do
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
      let(:structured_address) { Address.new(structured: structured_format ) }
      let(:address) { Address.new(line: line_format) }
      let(:coordinates_address) { Address.new(coordinates: coordinates_format) }

      it "when successful returns the resource" do
        stub_token_request
        stub_signup_request

        signup = subject.register_signup(installation_id: 'id', address: address)

        expected = JSON.parse(unknown_signup_fixture, symbolize_names: true)
        expect(signup.id).
          to eql expected[:id]
        expect(signup.risk_assessment).
          to eql expected[:risk_assessment]
        expect_evidences_to_match(signup, expected)
      end

      context "HTTP request" do
        it "hits the endpoint with installation_id and address_line" do
          stub_token_request

          stub = stub_signup_request
          stub.with(
            body: { installation_id: 'id', address_line: line_format },
            headers: {
              'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
            }
          )

          subject.register_signup(installation_id: 'id', address: address)

          expect(stub).to have_been_made.once
        end

        it "hits the endpoint with installation_id and structured_address" do
          stub_token_request

          stub = stub_signup_request
          stub.with(
            body: { installation_id: 'id', structured_address: structured_format },
            headers: {
              'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
            }
          )

          subject.register_signup(installation_id: 'id', address: structured_address)

          expect(stub).to have_been_made.once
        end

        it "hits the endpoint with installation_id and coordinates" do
          stub_token_request

          stub = stub_signup_request
          stub.with(
            body: { installation_id: 'id', address_coordinates: coordinates_format },
            headers: {
              'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
            }
          )

          subject.register_signup(installation_id: 'id', address: coordinates_address)

          expect(stub).to have_been_made.once
        end
      end

    end

    describe "#get_signup_assessment" do
      let(:signup_id) { 'id' }

      it "when successful returns the resource" do
        stub_token_request
        stub_get_signup_request(signup_id: signup_id)

        signup = subject.get_signup_assessment(signup_id: signup_id)

        expected = JSON.parse(unknown_signup_fixture, symbolize_names: true)
        expect(signup.id).
          to eql expected[:id]
        expect(signup.risk_assessment).
          to eql expected[:risk_assessment]
        expect_evidences_to_match(signup, expected)
      end

      context "HTTP request" do
        it "hits the endpoint with signup id at URL" do
          stub_token_request

          stub = stub_get_signup_request(signup_id: signup_id)
          stub.with(
            headers: {
              'Authorization' => /Bearer.*/
            }
          )

          subject.get_signup_assessment(signup_id: signup_id)

          expect(stub).to have_been_made.once
        end
      end

    end

    def expect_evidences_to_match(signup, expected)
      expect(signup.evidence.device_model).
        to eql expected[:evidence][:device_model]
      expect(signup.evidence.location_events_quantity).
        to eql expected[:evidence][:location_events_quantity]
      expect(signup.evidence.location_services.location_permission_enabled).
        to eql expected[:evidence][:location_services][:location_permission_enabled]
      expect(signup.evidence.location_services.location_sensors_enabled).
        to eql expected[:evidence][:location_services][:location_sensors_enabled]
    end
  end

end
