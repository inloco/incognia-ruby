require "faraday"
require "json"
require "logger"
require 'faraday_middleware'

module Incognia
  class Api
    # business layer: uses the Client to build domain objects
    # raises missing parameters errors
    attr_accessor :connection

    def initialize(client_id:, client_secret:)
      @connection = Client.new(client_id: client_id,
                               client_secret: client_secret,
                               host: "https://api.incognia.com/api")
    end

    def register_signup(request_token: nil, address: nil, **opts)
      params = {}
      params.merge!({ request_token: request_token }) if request_token
      params.merge!(opts)
      params.merge!(address&.to_hash) if address

      response = connection.request(
        :post,
        'v2/onboarding/signups',
        params
      )

      SignupAssessment.from_hash(response.body) if response.success?
    end

    def register_login(account_id:, request_token: nil, **opts)
      params = {
        type: :login,
        account_id: account_id
      }
      params.merge!({ request_token: request_token }) if request_token
      params.merge!(opts)

      response = connection.request(
        :post,
        'v2/authentication/transactions',
        params
      )

      LoginAssessment.from_hash(response.body) if response.success?
    end

    def register_feedback(event:, occurred_at: nil, expires_at: nil, timestamp: nil, **ids)
      if !timestamp.nil?
        warn("Deprecation warning: use occurred_at instead of timestamp")
      end

      timestamp = timestamp.strftime('%s%L') if timestamp.respond_to? :strftime
      occurred_at = occurred_at.to_datetime.rfc3339 if occurred_at.respond_to? :to_datetime
      expires_at = expires_at.to_datetime.rfc3339 if expires_at.respond_to? :to_datetime

      params = { event: event, timestamp: timestamp&.to_i, occurred_at: occurred_at, expires_at: expires_at }.compact
      params.merge!(ids)

      response = connection.request(
        :post,
        '/api/v2/feedbacks',
        params
      )

      response.success?
    end

    def register_payment(account_id:, request_token: nil, **opts)
      params = { account_id: account_id, type: :payment }
      params.merge!({ request_token: request_token }) if request_token
      params.merge!(opts)

      response = connection.request(
        :post,
        'v2/authentication/transactions',
        params
      )

      PaymentAssessment.from_hash(response.body) if response.success?
    end
  end
end
