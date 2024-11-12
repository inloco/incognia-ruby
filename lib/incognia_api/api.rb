require "faraday"
require "json"
require "logger"
require 'faraday_middleware'

module Incognia
  class Api
    class << self
      # business layer: uses the Client.instance to build domain objects
      # raises missing parameters errors

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

      def register_feedback(event:, occurred_at: nil, expires_at: nil, **ids)
        occurred_at = occurred_at.to_datetime.rfc3339 if occurred_at.respond_to? :to_datetime
        expires_at = expires_at.to_datetime.rfc3339 if expires_at.respond_to? :to_datetime

        params = { event: event, occurred_at: occurred_at, expires_at: expires_at }.compact
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
