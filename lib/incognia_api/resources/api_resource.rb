require 'delegate'

module Incognia
  class APIResource < OpenStruct
    def self.from_hash(hash)
      hash = hash.each_with_object({}) do |(k, v), h|
        h[k] = v.is_a?(Hash) ? from_hash(v) : v
      end

      new(hash)
    end
  end
end
