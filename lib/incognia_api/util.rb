module Incognia
  module Util
    OS_HOST = RbConfig::CONFIG['host']
    OS_ARCH = RbConfig::CONFIG['arch']
    LANGUAGE_VERSION = RbConfig::CONFIG['ruby_version']

    def self.symbolize_names(object)
      case object
      when Hash
        new_hash = {}
        object.each do |key, value|
          key = (begin key.to_sym; rescue StandardError; key end) || key
          new_hash[key] = symbolize_names(value)
        end
        new_hash
      when Array
        object.map { |value| symbolize_names(value) }
      else
        object
      end
    end
  end
end
