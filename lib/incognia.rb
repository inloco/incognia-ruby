# frozen_string_literal: true

require_relative "incognia/version"
require_relative "incognia/client"
require_relative "incognia/util"
require_relative "incognia/address"
require_relative "incognia/api"

require_relative "incognia/resources/api_resource"
require_relative "incognia/resources/signup_assessment"
require_relative "incognia/resources/login_assessment"
require_relative "incognia/resources/credentials"

require_relative "incognia/constants/feedback_event"

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
