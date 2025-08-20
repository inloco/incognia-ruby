# frozen_string_literal: true
require 'securerandom'

module Incognia
  RSpec.describe '.configure' do
    it 'sets configuration on Configuration.instance' do
      config = {
        client_id: SecureRandom.uuid,
        client_secret: SecureRandom.uuid,
        host: 'https://api.incognia.com/api'
      }

      Incognia.configure(**config)

      expect(Configuration.instance.client_id).to eq(config[:client_id])
      expect(Configuration.instance.client_secret).to eq(config[:client_secret])
      expect(Configuration.instance.host).to eq(config[:host])
    end
  end

  RSpec.describe '.config' do
    it 'returns the instance of Configuration' do
      expect(Incognia.config).to eq(Configuration.instance)
    end
  end

  RSpec.describe Incognia::Api do
    before do
      Incognia.configure(
        client_id: 'client_id',
        client_secret: 'client_secret',
        host: 'https://api.incognia.com/api'
      )
    end

    describe ".register_signup" do
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
      let(:request_token) { SecureRandom.uuid }
      let(:person_id) { PersonId.new(type: "cpf", value: "12345678901") }

      it "when successful returns the resource" do
        stub_token_request
        stub_signup_request

        signup = described_class.register_signup(request_token: request_token, address: address, person_id: person_id)

        expected = JSON.parse(unknown_signup_fixture, symbolize_names: true)
        expect(signup.id).
          to eql expected[:id]
        expect(signup.risk_assessment).
          to eql expected[:risk_assessment]
        expect_evidences_to_match(signup, expected)
      end

      context "HTTP request" do
        shared_examples_for 'receiving one of the required tokens' do |token_name|
          let(:token_value) { SecureRandom.uuid }

          it "hits the endpoint with #{token_name}" do
            stub_token_request

            stub = stub_signup_request
            stub.with(
              body: { token_name => token_value },
              headers: {
                'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
              }
            )

            described_class.register_signup(token_name => token_value)

            expect(stub).to have_been_made.once
          end
        end

        it_behaves_like 'receiving one of the required tokens', :request_token
        it_behaves_like 'receiving one of the required tokens', :installation_id
        it_behaves_like 'receiving one of the required tokens', :session_token

        it "hits the endpoint with request_token and address_line" do
          stub_token_request

          stub = stub_signup_request.with(
            body: { request_token: request_token, address_line: line_format },
            headers: {
              'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
            }
          )

          described_class.register_signup(request_token: request_token, address: address)

          expect(stub).to have_been_made.once
        end

        it "hits the endpoint with request_token and structured_address" do
          stub_token_request

          stub = stub_signup_request
          stub.with(
            body: { request_token: request_token, structured_address: structured_format },
            headers: {
              'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
            }
          )

          described_class.register_signup(request_token: request_token, address: structured_address)

          expect(stub).to have_been_made.once
        end

        it "hits the endpoint with request_token and coordinates" do
          stub_token_request

          stub = stub_signup_request
          stub.with(
            body: { request_token: request_token, address_coordinates: coordinates_format },
            headers: {
              'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
            }
          )

          described_class.register_signup(request_token: request_token, address: coordinates_address)

          expect(stub).to have_been_made.once
        end

        context 'when receiving any other optional arguments' do
          shared_examples_for 'receiving optional args' do |optional_arguments|
            it "hits the endpoint also with #{optional_arguments}" do
              stub_token_request

              stub = stub_signup_request.with(
                body: { request_token: request_token }.merge(opts),
                headers: {
                  'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
                }
              )

              described_class.register_signup(
                request_token: request_token,
                **opts
              )

              expect(stub).to have_been_made.once
            end
          end

          it_behaves_like 'receiving optional args', 'account_id' do
            let(:opts) { { account_id: SecureRandom.uuid } }
          end
          it_behaves_like 'receiving optional args', 'external_id' do
            let(:opts) { { external_id: SecureRandom.uuid } }
          end
          it_behaves_like 'receiving optional args', 'policy_id' do
            let(:opts) { { policy_id: SecureRandom.uuid } }
          end
        end
      end
    end

    describe ".register_login" do
      let(:request_token) { SecureRandom.uuid }
      let(:account_id) { SecureRandom.uuid }
      let(:person_id) {PersonId.new(type: "cpf", value: "12345678901")}

      it "when successful returns the resource" do
        stub_token_request
        stub_login_request

        login = described_class.register_login(
          request_token: request_token,
          account_id: account_id,
          person_id: person_id
        )

        expected = JSON.parse(unknown_login_fixture, symbolize_names: true)
        expect(login.id).to eql expected[:id]
        expect(login.risk_assessment).to eql expected[:risk_assessment]
        expect_evidences_to_match(login, expected)
      end

      context "HTTP request" do
        shared_examples_for 'receiving one of the required tokens with account_id' do |token_name|
          let(:token_value) { SecureRandom.uuid }

          it "hits the endpoint with #{token_name} and account_id" do
            stub_token_request

            stub = stub_login_request.with(
              body: {
                type: 'login',
                account_id: account_id,
                token_name => token_value
              },
              headers: {
                'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
              }
            )

            described_class.register_login(
              account_id: account_id,
              token_name => token_value
            )

            expect(stub).to have_been_made.once
          end
        end

        it_behaves_like 'receiving one of the required tokens with account_id', :request_token
        it_behaves_like 'receiving one of the required tokens with account_id', :installation_id
        it_behaves_like 'receiving one of the required tokens with account_id', :session_token

        shared_examples_for 'a login request that includes location in the request body' do

          it 'includes location in the request body' do
            stub_token_request
        
            body = {
              type: 'login',
              request_token: request_token,
              account_id: account_id,
              location: location.to_hash,
            }
        
            stub = stub_login_request.with(
              body: body,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => /Bearer.*/
              }
            )
        
            described_class.register_login(
              request_token: request_token,
              account_id: account_id,
              location: location,
            )
        
            expect(stub).to have_been_made.once
          end
        end

        context 'when location with a timestamp is provided' do
          let(:location) { Location.new(latitude: 37.7749, longitude: -122.4194, collected_at: "2025-04-27T05:03:45-02:00") }
          it_behaves_like 'a login request that includes location in the request body'
        end

        context 'when location without a timestamp is provided' do
          let(:location) { Location.new(latitude: 37.7749, longitude: -122.4194) }
          it_behaves_like 'a login request that includes location in the request body'
        end
  
        context 'when receiving any other optional arguments' do
          shared_examples_for 'receiving optional args' do |optional_arguments|
            it "hits the endpoint also with #{optional_arguments}" do
              stub_token_request

              stub = stub_login_request.with(
                body: {
                  type: 'login',
                  request_token: request_token,
                  account_id: account_id
                }.merge(opts),
                headers: {
                  'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
                }
              )

              described_class.register_login(
                request_token: request_token,
                account_id: account_id,
                **opts
              )

              expect(stub).to have_been_made.once
            end
          end

          it_behaves_like 'receiving optional args', 'external_id' do
            let(:opts) { { external_id: 'external-id' } }
          end
          it_behaves_like 'receiving optional args', 'eval' do
            let(:opts) { { eval: false } }
          end
          it_behaves_like 'receiving optional args', 'external_id and eval' do
            let(:opts) { { external_id: 'external-id', eval: false } }
          end
        end
      end

    end

    describe ".register_payment" do
      let(:request_token) { SecureRandom.uuid }
      let(:account_id) { SecureRandom.uuid }
      let(:person_id) {PersonId.new(type: "cpf", value: "12345678901")}

      it "when successful returns the resource" do
        stub_token_request
        stub_payment_request

        payment = described_class.register_payment(
          request_token: request_token,
          account_id: account_id,
          person_id: person_id
        )

        expected = JSON.parse(unknown_payment_fixture, symbolize_names: true)
        expect(payment.id).to eql expected[:id]
        expect(payment.risk_assessment).to eql expected[:risk_assessment]
        expect_evidences_to_match(payment, expected)
      end

      context "HTTP request" do
        shared_examples_for 'receiving one of the required tokens with account_id' do |token_name|
          let(:token_value) { SecureRandom.uuid }

          it "hits the endpoint with #{token_name} and account_id" do
            stub_token_request

            stub = stub_payment_request.with(
              body: {
                type: 'payment',
                account_id: account_id,
                token_name => token_value
              },
              headers: {
                'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
              }
            )

            described_class.register_payment(
              account_id: account_id,
              token_name => token_value
            )

            expect(stub).to have_been_made.once
          end
        end

        it_behaves_like 'receiving one of the required tokens with account_id', :request_token
        it_behaves_like 'receiving one of the required tokens with account_id', :installation_id
        it_behaves_like 'receiving one of the required tokens with account_id', :session_token

        shared_examples_for 'a payment request that includes location in the request body' do
          it 'includes location in the request body' do
            stub_token_request
        
            body = {
              type: 'payment',
              request_token: request_token,
              account_id: account_id,
              location: location.to_hash,
            }
        
            stub = stub_payment_request.with(
              body: body,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => /Bearer.*/
              }
            )
        
            described_class.register_payment(
              request_token: request_token,
              account_id: account_id,
              location: location,
            )
        
            expect(stub).to have_been_made.once
          end
        end

        context 'when location with a timestamp is provided' do
          let(:location) { Location.new(latitude: 37.7749, longitude: -122.4194, collected_at: "2025-04-27T05:03:45-02:00") }
          it_behaves_like 'a payment request that includes location in the request body'
        end

        context 'when location without a timestamp is provided' do
          let(:location) { Location.new(latitude: 37.7749, longitude: -122.4194) }
          it_behaves_like 'a payment request that includes location in the request body'
        end

        context 'when receiving any other optional arguments' do
          shared_examples_for 'receiving optional args' do |optional_arguments|
            it "hits the endpoint also with #{optional_arguments}" do
              stub_token_request

              stub = stub_payment_request.with(
                body: {
                  type: 'payment',
                  request_token: request_token,
                  account_id: account_id
                }.merge(opts),
                headers: {
                  'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
                }
              )

              described_class.register_payment(
                request_token: request_token,
                account_id: account_id,
                **opts
              )

              expect(stub).to have_been_made.once
            end
          end

          it_behaves_like 'receiving optional args', 'external_id' do
            let(:opts) { { external_id: 'external-id' } }
          end
          it_behaves_like 'receiving optional args', 'payment_value' do
            let(:opts) { { payment_value: { 'amount': 5.0, 'currency': 'BRL' } } }
          end
          it_behaves_like 'receiving optional args', 'external_id and payment_value' do
            let(:opts) { { external_id: 'external-id', payment_value: 12.5 } }
          end
        end
      end
    end

    describe ".register_feedback" do
      let(:event) { Incognia::Constants::FeedbackEvent.constants.sample.to_s }
      let(:occurred_at) { '2024-03-13T10:12:01Z' }
      let(:expires_at) { '2024-03-13T10:12:02Z' }
      let(:person_id) {PersonId.new(type: "cpf", value: "12345678901")}

      before do
        allow(described_class).to receive(:warn)

        stub_token_request
      end


      it "when successful returns true" do
        stub_register_feedback_request

        feedback_registered = described_class.register_feedback(event: event)
        expect(feedback_registered).to be(true)
      end

      context "HTTP request" do
        it "hits the endpoint with event, occurred_at and expires_at" do
          stub = stub_register_feedback_request
          stub.with(
            body: { event: event, occurred_at: occurred_at, expires_at: expires_at },
            headers: {
              'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
            }
          )

          described_class.register_feedback(event: event, occurred_at: occurred_at, expires_at: expires_at)

          expect(stub).to have_been_made.once
        end

        it "hits the endpoint with event and person_id" do
          stub = stub_register_feedback_request
          stub.with(
            body: {
              event: event,
              person_id: person_id.to_hash
            },
            headers: {
              'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
            }
          )

          described_class.register_feedback(event: event, person_id: person_id)

          expect(stub).to have_been_made.once
        end

        context "when receiving occurred_at as a Time" do
          let(:occurred_at) { Time.now }

          it "hits the endpoint with expires_at in RFC3339" do
            stub = stub_register_feedback_request.with(
              body: { event: event, occurred_at: occurred_at.to_datetime.rfc3339 },
              headers: {
                'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
              }
            )

            described_class.register_feedback(event: event, occurred_at: occurred_at)

            expect(stub).to have_been_made.once
          end
        end

        context "when receiving occurred_at as a DateTime" do
          let(:occurred_at) { DateTime.now }

          it "hits the endpoint with occurred_at in RFC3339" do
            stub = stub_register_feedback_request.with(
              body: { event: event, occurred_at: occurred_at.to_datetime.rfc3339 },
              headers: {
                'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
              }
            )

            described_class.register_feedback(event: event, occurred_at: occurred_at)

            expect(stub).to have_been_made.once
          end
        end

        context "when not receiving occurred_at" do
          it "hits the endpoint without occurred_at" do
            stub = stub_register_feedback_request.with(
              body: { event: event },
              headers: {
                'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
              }
            )

            described_class.register_feedback(event: event)

            expect(stub).to have_been_made.once
          end
        end

        context "when receiving expires_at as a Time" do
          let(:expires_at) { Time.now }

          it "hits the endpoint with expires_at in RFC3339" do
            stub = stub_register_feedback_request.with(
              body: { event: event, expires_at: expires_at.to_datetime.rfc3339 },
              headers: {
                'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
              }
            )

            described_class.register_feedback(event: event, expires_at: expires_at)

            expect(stub).to have_been_made.once
          end
        end

        context "when receiving expires_at as a DateTime" do
          let(:expires_at) { DateTime.now }

          it "hits the endpoint with expires_at in RFC3339" do
            stub = stub_register_feedback_request.with(
              body: { event: event, expires_at: expires_at.to_datetime.rfc3339 },
              headers: {
                'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
              }
            )

            described_class.register_feedback(event: event, expires_at: expires_at)

            expect(stub).to have_been_made.once
          end
        end

        context "when not receiving expires_at" do
          it "hits the endpoint without expires_at" do
            stub = stub_register_feedback_request.with(
              body: { event: event },
              headers: {
                'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
              }
            )

            described_class.register_feedback(event: event)

            expect(stub).to have_been_made.once
          end
        end

        context "when receiving ids" do
          shared_examples_for "receiving ids" do |id_name|
            let(:id) { SecureRandom.uuid }

            it "hits the endpoint with #{id_name}" do
              stub = stub_register_feedback_request.with(
                body: { event: event, occurred_at: occurred_at, expires_at: expires_at, id_name => id },
                headers: {
                  'Content-Type' => 'application/json', 'Authorization' => /Bearer.*/
                }
              )

              described_class.register_feedback(event: event, occurred_at: occurred_at, expires_at: expires_at, id_name => id)

              expect(stub).to have_been_made.once
            end
          end

          it_behaves_like 'receiving ids', :request_token
          it_behaves_like 'receiving ids', :account_id
          it_behaves_like 'receiving ids', :external_id
          it_behaves_like 'receiving ids', :signup_id
          it_behaves_like 'receiving ids', :login_id
          it_behaves_like 'receiving ids', :payment_id
          it_behaves_like 'receiving ids', :session_token
        end
      end
    end

    def expect_evidences_to_match(model, expected)
      expect(model.evidence.device_model).
        to eql expected[:evidence][:device_model]
      expect(model.evidence.location_services.location_permission_enabled).
        to eql expected[:evidence][:location_services][:location_permission_enabled]
      expect(model.evidence.location_services.location_sensors_enabled).
        to eql expected[:evidence][:location_services][:location_sensors_enabled]
    end
  end
end
