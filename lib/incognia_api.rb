# frozen_string_literal: true

require_relative "incognia_api/version"
require_relative "incognia_api/client"
require_relative "incognia_api/util"
require_relative "incognia_api/address"
require_relative "incognia_api/api"

require_relative "incognia_api/resources/api_resource"
require_relative "incognia_api/resources/signup_assessment"
require_relative "incognia_api/resources/login_assessment"
require_relative "incognia_api/resources/payment_assessment"
require_relative "incognia_api/resources/credentials"

require_relative "incognia_api/constants/feedback_event"

module Incognia
  class APIError < StandardError
    attr_reader :message, :errors, :status

    def initialize(message, response_info = {})
      @status = response_info[:status]
      @errors = response_info[:body]
      @message = format_message(message)
    end

    def to_s
      message
    end

    def format_message(initial_message)
      message = "[HTTP #{status}]: #{initial_message}"
      message += "\n#{errors}" if errors
    end
  end

  class APIAuthenticationError < StandardError
    def to_s
      "Informed credentials failed"
    end
  end
  # Your code goes here...
end
