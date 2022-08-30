require 'ostruct'

module Incognia
  class Credentials < APIResource
    STALE_BEFORE = 10

    def stale?
      Time.now >= (generated_at + expires_in.to_i - STALE_BEFORE)
    end
  end
end
