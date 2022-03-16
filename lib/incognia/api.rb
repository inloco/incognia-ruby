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

    def register_signup(installation_id:, address: )
      response = connection.request(
        :post,
        'v2/onboarding/signups',
        installation_id: installation_id,
        **address.to_hash
      )

      SignupAssessment.from_hash(response.body) if response.success?
    end
  end

end
