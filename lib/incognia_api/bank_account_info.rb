# frozen_string_literal: true

require_relative "pix_key"
require_relative "person_id"

module Incognia
  class BankAccountInfo
    attr_reader :account_type, :account_purpose, :holder_type, :holder_tax_id,
      :country, :ispb_code, :branch_code, :account_number,
      :account_check_digit, :pix_keys

    def initialize(
      holder_type:, holder_tax_id:, branch_code:, account_number:, account_type: nil,
      account_purpose: nil,
      country: nil,
      ispb_code: nil,
      account_check_digit: nil,
      pix_keys: []
    )
      @account_type = account_type
      @account_purpose = account_purpose
      @holder_type = holder_type
      @holder_tax_id = holder_tax_id
      @country = country
      @ispb_code = ispb_code
      @branch_code = branch_code
      @account_number = account_number
      @account_check_digit = account_check_digit
      @pix_keys = pix_keys
    end

    def to_hash
      h = {
        account_type: account_type,
        account_purpose: account_purpose,
        holder_type: holder_type,
        country: country,
        ispb_code: ispb_code,
        branch_code: branch_code,
        account_number: account_number,
        account_check_digit: account_check_digit
      }.compact

      if holder_tax_id
        h[:holder_tax_id] =
          holder_tax_id.respond_to?(:to_hash) ? holder_tax_id.to_hash : holder_tax_id
      end

      if pix_keys && !pix_keys.empty?
        h[:pix_keys] = pix_keys.map { |k| k.respond_to?(:to_hash) ? k.to_hash : k }
      end

      h
    end
  end
end
