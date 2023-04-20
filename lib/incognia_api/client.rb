require "time"

module Incognia
  class Client
    # TODO:
    # (ok) http/adapter specific code
    # (ok) raises network/authentication errors
    # (ok) handles token refreshing ok
    # future: handles retrying
    attr_reader :connection

    def initialize(client_id:, client_secret:, host:)
      @client_id = client_id
      @client_secret = client_secret
      @host = host

      @connection = Faraday.new(host) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
        faraday.response :raise_error

        faraday.adapter Faraday.default_adapter
      end
    end

    def request(method, endpoint = nil, data = nil, headers = {})
      json_data = JSON.generate(data) if data

      connection.send(method, endpoint, json_data, headers) do |r|
        r.headers[Faraday::Request::Authorization::KEY] ||= Faraday::Request
          .lookup_middleware(:authorization)
          .header(:Bearer, credentials.access_token)
      end
    rescue Faraday::ClientError, Faraday::ServerError => e
      raise APIError.new(e.to_s, e.response)
    rescue Faraday::Error => e
      raise APIError.new(e.to_s)
    end

    def credentials
      @credentials = request_credentials if @credentials.nil? || @credentials.stale?

      @credentials
    end

    protected

    def request_credentials
      basic_auth = Faraday::Request
        .lookup_middleware(:basic_auth)
        .header(@client_id, @client_secret)

      response = connection.send(:post, 'v2/token') do |r|
        r.headers[Faraday::Request::Authorization::KEY] = basic_auth
      end

      response.success? ? build_credentials(response) : nil
    rescue Faraday::UnauthorizedError => e
      raise APIAuthenticationError
    rescue Faraday::Error => e
      raise APIError.new(e.to_s)
    end

    def build_credentials(raw_response)
      body = raw_response.body
      response_date = raw_response.headers['Date']

      properties = body.merge(
        generated_at: response_date ? Time.parse(response_date) : Time.now
      )

      Credentials.from_hash(properties)
    end

  end
end
