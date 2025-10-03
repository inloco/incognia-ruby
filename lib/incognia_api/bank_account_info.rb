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
      {
        account_type:,
        account_purpose:,
        holder_type:,
        country:,
        ispb_code:,
        branch_code:,
        account_number:,
        account_check_digit:,
        holder_tax_id: serialize_hash(holder_tax_id),
        pix_keys: pix_keys&.map { |k| serialize_hash(k) }
      }.compact
    end
    
    private
    
    def serialize_hash(value)
      value.respond_to?(:to_hash) ? value.to_hash : value
    end
  end
end
