require "faraday"
require "json"
require "logger"

module Incognia
  class Api
    class << self
      # business layer: uses the Client.instance to build domain objects
      # raises missing parameters errors

      def register_signup(request_token: nil, address: nil, person_id: nil, **opts)
        params = { request_token: request_token }.compact
        params.merge!(opts)
        params.merge!(address.to_hash) if address
        params.merge!(person_id: person_id.to_hash) if person_id

        response = connection.request(
          :post,
          'v2/onboarding/signups',
          params
        )

        SignupAssessment.from_hash(response.body) if response.success?
      end

      def register_login(account_id:, request_token: nil, location: nil, person_id: nil, **opts)
        params = {
          type: :login,
          account_id: account_id,
          request_token: request_token
        }.compact
        params.merge!(location: location.to_hash) if location
        params.merge!(person_id: person_id.to_hash) if person_id
        params.merge!(opts)

        response = connection.request(
          :post,
          'v2/authentication/transactions',
          params
        )

        LoginAssessment.from_hash(response.body) if response.success?
      end

      def register_feedback(event:, occurred_at: nil, expires_at: nil, person_id: nil, **ids)
        occurred_at = occurred_at.to_datetime.rfc3339 if occurred_at.respond_to? :to_datetime
        expires_at = expires_at.to_datetime.rfc3339 if expires_at.respond_to? :to_datetime

        params = { event: event, occurred_at: occurred_at, expires_at: expires_at }.compact
        params.merge!(person_id: person_id.to_hash) if person_id
        params.merge!(ids)

        response = connection.request(
          :post,
          '/api/v2/feedbacks',
          params
        )

        response.success?
      end

      def register_payment(account_id:, request_token: nil, location: nil, person_id: nil, debtor_account: nil, creditor_account: nil, **opts)
        params = {
          type: :payment,
          account_id: account_id,
          request_token: request_token
        }.compact
        params.merge!(location: location.to_hash) if location
        params.merge!(person_id: person_id.to_hash) if person_id
        params.merge!(debtor_account: debtor_account.to_hash) if debtor_account
        params.merge!(creditor_account: creditor_account.to_hash) if creditor_account
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
