require "time"
require "singleton"

module Incognia
  class Client
    include Singleton
    # TODO:
    # (ok) http/adapter specific code
    # (ok) raises network/authentication errors
    # (ok) handles token refreshing ok
    # future: handles retrying

    def request(method, endpoint = nil, data = nil, headers = {})
      json_data = JSON.generate(data) if data

      connection.send(method, endpoint, json_data, headers) do |r|
        r.headers[Faraday::Request::Authorization::KEY] ||= "Bearer #{credentials.access_token}"
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

    def connection
      return @connection if @connection

      headers = { 'User-Agent' => "incognia-ruby/#{Incognia::VERSION} " \
                          "({#{RbConfig::CONFIG['host']}}) " \
                          "{#{RbConfig::CONFIG['arch']}} " \
                          "Ruby/#{RbConfig::CONFIG['ruby_version']}" }

      @connection = Faraday.new(Incognia.config.host, headers: headers) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
        faraday.response :raise_error

        faraday.adapter Faraday.default_adapter
      end
    end

    protected

    def request_credentials
      basic_auth = Faraday::Utils
        .basic_header_from(Incognia.config.client_id, Incognia.config.client_secret)

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
