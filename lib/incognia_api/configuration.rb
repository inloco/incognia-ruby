require 'singleton'

module Incognia
  class Configuration
    include Singleton

    attr_accessor :client_id, :client_secret, :host, :keep_alive, :max_connections

    def configure(client_id:, client_secret:, host: nil, keep_alive: false, max_connections: nil)
      validate_connection_settings!(keep_alive: keep_alive, max_connections: max_connections)

      @client_id = client_id
      @client_secret = client_secret
      @host = host || 'https://api.incognia.com/api'
      @keep_alive = keep_alive
      @max_connections = max_connections

      self
    end

    private

    def validate_connection_settings!(keep_alive:, max_connections:)
      return if max_connections.nil?

      raise ArgumentError, 'max_connections requires keep_alive: true' unless keep_alive
      raise ArgumentError, 'max_connections must be a positive Integer' unless max_connections.is_a?(Integer) && max_connections.positive?
    end
  end
end
