module Incognia
  RSpec.describe Client do
    let(:sample_hash) { { foo: "bar" } }
    let(:sample_json) { JSON.generate(sample_hash) }
    let(:token_fixture) { File.new("spec/fixtures/token.json").read }
    let(:test_endpoint) { "https://api.incognia.com/api/v2/endpoint" }

    subject(:instance) { described_class.instance }

    before do
      Incognia.configure(
        client_id: 'client_id',
        client_secret: 'client_secret',
        host: 'https://api.incognia.com/api'
      )
    end

    describe "#request" do
      it "makes an HTTP request" do
        stub_token_request
        stub = stub_request(:post, test_endpoint).
          with(body: sample_json).
          to_return(
            status: 200,
            body: sample_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        instance.request(:post, 'v2/endpoint', { foo: :bar })

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

          instance.request(
            :post,
            "v2/endpoint",
            { foo: :bar }
          )

          expect(stub).to have_been_made.once
      end

      it "injects User-Agent header" do
        user_agent_header = { 'User-Agent' => "incognia-ruby/#{Incognia::VERSION} " \
                              "({#{RbConfig::CONFIG['host']}}) " \
                              "{#{RbConfig::CONFIG['arch']}} " \
                              "Ruby/#{RbConfig::CONFIG['ruby_version']}" }

        stub_token_request
        stub = stub_request(:post, test_endpoint)
          .with(
            body: sample_json,
            headers: user_agent_header
          ).to_return(
            status: 200,
            body: sample_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        instance.request(
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

          instance.request(
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

        expect(instance.request(:post, 'v2/endpoint')).to be_success
        expect(instance.request(:post, 'v2/endpoint').body['foo']).to eq('bar')
      end

      context "when receives errors" do
        it "raises exception when 4xx" do
          stub_token_request
          stub_signup_request_400(error: :example)

          expect {
            instance.request(:post, "v2/onboarding/signups")
          }.to raise_exception APIError, /server responded with status 400/i
        end

        it "raises exception when 5xx" do
          stub_token_request
          stub_signup_request_500

          expect {
            instance.request(:post, "v2/onboarding/signups")
          }.to raise_exception APIError
        end

        it "raises exception when is another error" do
          stub_token_request
          stub_request_timeout("v2/onboarding/signups")

          expect {
            instance.request(:post, "v2/onboarding/signups")
          }.to raise_exception APIError
        end
      end
    end

    describe "#credentials" do
      before { Singleton.__init__(described_class) }

      it "requests an access token from the /token endpoint" do
        stub = stub_token_request

        credentials = instance.credentials

        expect(credentials).to_not be_nil
        expect(stub).to have_been_made.once
      end

      it "provides the access_token and expires_in" do
        stub_token_request

        credentials = instance.credentials

        expect(credentials.access_token).to be
        expect(credentials.expires_in).to be
        expect(credentials.generated_at).to be
      end

      it "caches the access_token in any instance" do
        stub = stub_token_request

        2.times { described_class.instance.credentials }

        expect(stub).to have_been_made.once
      end

      context "when token is outdated" do
        it "calls the /token endpoint again" do
          stub = stub_token_request

          instance.credentials
          Timecop.travel(Time.now + 1200) { instance.credentials }

          expect(stub).to have_been_made.twice
        end
      end

      context "when receives unauthorized error" do
        it "raises APIAuthenticationError" do
          stub_token_request_401

          expect {
            instance.credentials
          }.to raise_exception APIAuthenticationError
        end
      end

      context "when receives other errors" do
        it "raises APIError" do
          stub_request_timeout("v2/token")

          expect {
            instance.credentials
          }.to raise_exception APIError
        end
      end
    end

  end

end
