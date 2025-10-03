# frozen_string_literal: true

module Incognia
  class PixKey
    attr_reader :type, :value

    def initialize(type:, value:)
      @type = type
      @value = value
    end

    def to_hash
      {type: type, value: value}
    end
  end
end
