module Incognia
  RSpec.describe Client do
    let(:sample_hash) { { foo: "bar" } }
    let(:sample_json) { JSON.generate(sample_hash) }
    let(:token_fixture) { File.new("spec/fixtures/token.json").read }
    let(:test_endpoint) { "https://api.incognia.com/api/v2/endpoint" }

    subject do
      described_class.new(
        client_id: 'client_id',
        client_secret: 'client_secret',
        host: 'https://api.incognia.com/api'
      )
    end

    context "#request" do
      it "makes an HTTP request" do
        stub_token_request
        stub = stub_request(:post, test_endpoint).
          with(body: sample_json).
          to_return(
            status: 200,
            body: sample_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        subject.request(:post, 'v2/endpoint', { foo: :bar })

        expect(stub).to have_been_made.once
      end

      it "injects Authorization header with access_token" do
        stub_token_request
        stub = stub_request(:post, test_endpoint).
          with(
            body: sample_json,
            headers: { 'Authorization'=> "Bearer #{JSON.parse(token_fixture)["access_token"]}" }
          ).
          to_return(
            status: 200,
            body: sample_json,
            headers: { 'Content-Type' => 'application/json' }
          )

          subject.request(
            :post,
            "v2/endpoint",
            { foo: :bar }
          )

          expect(stub).to have_been_made.once
      end

      context "when passing an Authorization header" do
        it  "overrides default header" do
          stub = stub_request(:post, test_endpoint).
            with( body: sample_json, headers: { 'Authorization'=>'token' }).
            to_return(
              status: 200,
              body: sample_json,
              headers: { 'Content-Type' => 'application/json' }
            )

          subject.request(
            :post,
            'v2/endpoint',
            { foo: :bar },
            'Authorization' => 'token'
          )

          expect(stub).to have_been_made.once
        end
      end

      it "returns the correct body" do
        stub_token_request

        stub = stub_request(:post, test_endpoint).
          to_return(
            status: 200,
            body: sample_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        expect(subject.request(:post, 'v2/endpoint')).to be_success
        expect(subject.request(:post, 'v2/endpoint').body['foo']).to eq('bar')
      end

      context "when 4xx" do
        it "raises exception when 4xx" do
          stub_token_request
          stub_signup_request_400(error: :example)

          expect {
            subject.request(:post, "v2/onboarding/signups")
          }.to raise_exception APIError, /server responded with status 400/i
        end

        it "raises exception when 5xx" do
          stub_token_request
          stub_signup_request_500

          expect {
            subject.request(:post, "v2/onboarding/signups")
          }.to raise_exception APIError
        end
      end
    end

    context "#credentials" do
      it "requests an access token from the /token endpoint" do
        stub = stub_token_request

        credentials = subject.credentials

        expect(credentials).to_not be_nil
        expect(stub).to have_been_made.once
      end

      it "provides the access_token and expires_in" do
        stub_token_request

        credentials = subject.credentials

        expect(credentials.access_token).to be
        expect(credentials.expires_in).to be
        expect(credentials.generated_at).to be
      end

      it "caches the access_token" do
        stub = stub_token_request

        2.times { subject.credentials }

        expect(stub).to have_been_made.once
      end

      context "when token is outdated" do
        it "calls the /token endpoint again" do
          stub = stub_token_request

          subject.credentials
          Timecop.travel(Time.now + 1200) { subject.credentials }

          expect(stub).to have_been_made.twice
        end
      end
    end

  end

end
