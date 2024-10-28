require 'singleton'

module Incognia
  class Configuration
    include Singleton

    attr_accessor :client_id, :client_secret, :host

    def configure(client_id:, client_secret:, host: nil)
      @client_id = client_id
      @client_secret = client_secret
      @host = host || 'https://api.incognia.com/api'

      self
    end
  end
end
