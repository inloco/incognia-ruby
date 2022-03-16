module APISpecHelpers
  def self.included(rspec)
    rspec.let(:token_fixture) do
      File.new("spec/fixtures/token.json").read
    end
    rspec.let(:unknown_signup_fixture) do
      File.new("spec/fixtures/signup-unknown.json").read
    end
    rspec.let(:missing_required_params_fixture) do
      File.new("spec/fixtures/missing-required-params.json").read
    end
  end

  def url_regex(endpoint)
    Regexp.new("https://")
  end

  def stub_token_request
    stub_request(:post, "https://api.incognia.com/api/v2/token").
      to_return(
        status: 200,
        body: token_fixture,
        headers: { 'Content-Type' => 'application/json', 'Date' => Time.now.utc })
  end

  def stub_signup_request
    stub_request(:post, "https://api.incognia.com/api/v2/onboarding/signups").
      to_return(
        status: 200,
        body: unknown_signup_fixture,
        headers: { 'Content-Type' => 'application/json' })
  end

  def stub_signup_request_400(error = nil)
    response_body = error ? JSON.generate(error) : missing_required_params_fixture

    stub_request(:post, "https://api.incognia.com/api/v2/onboarding/signups").
      to_return(
        status: 400,
        body: response_body,
        headers: { 'Content-Type' => 'application/json' })
  end

  def stub_signup_request_500
    stub_request(:post, "https://api.incognia.com/api/v2/onboarding/signups").
      to_return(
        status: 500,
        headers: { 'Content-Type' => 'application/json' })
  end
end
