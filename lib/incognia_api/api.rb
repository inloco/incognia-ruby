require "faraday"
require "json"
require "logger"
require 'faraday_middleware'

module Incognia
  class Api
    # business layer: uses the Client.instance to build domain objects
    # raises missing parameters errors

    def initialize(client_id:, client_secret:)
      Incognia.configure(client_id: client_id, client_secret: client_secret)

      warn("Deprecation warning: The Incognia::Api instance will be removed. " +
           "Please set up with `Incognia.configure` and use class methods instead.")
    end

    def register_signup(**args); self.class.register_signup(**args) end
    def register_login(**args); self.class.register_login(**args) end
    def register_feedback(**args); self.class.register_feedback(**args) end
    def register_payment(**args); self.class.register_payment(**args) end
    def connection
      warn("Deprecation warning: #connection and .connection are deprecated and will be private.")

      self.class.connection
    end

    class << self
      def register_signup(request_token: nil, address: nil, **opts)
        params = { request_token: request_token }.compact
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
          account_id: account_id,
          request_token: request_token
        }.compact
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
        params = {
          type: :payment,
          account_id: account_id,
          request_token: request_token
        }.compact
        params.merge!(opts)

        response = connection.request(
          :post,
          'v2/authentication/transactions',
          params
        )

        PaymentAssessment.from_hash(response.body) if response.success?
      end

      def connection
        Client.instance
      end
    end
  end
end
