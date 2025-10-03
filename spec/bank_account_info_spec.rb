require "spec_helper"

module Incognia
  RSpec.describe BankAccountInfo do
    let(:account_type) { "savings" }
    let(:account_purpose) { "rural" }
    let(:holder_type) { "business" }
    let(:holder_tax_id) { Incognia::PersonId.new(type: "cpf", value: "12345678901") }
    let(:country) { "BR" }
    let(:ispb_code) { "18236120" }
    let(:branch_code) { "0001" }
    let(:account_number) { "123456" }
    let(:account_check_digit) { "0" }
    let(:pix_keys) do
      [
        Incognia::PixKey.new(type: "cpf", value: "12345678901"),
        Incognia::PixKey.new(type: "email", value: "human@being.com")
      ]
    end

    subject(:bank_account_info) do
      described_class.new(
        account_type: account_type,
        account_purpose: account_purpose,
        holder_type: holder_type,
        holder_tax_id: holder_tax_id,
        country: country,
        ispb_code: ispb_code,
        branch_code: branch_code,
        account_number: account_number,
        account_check_digit: account_check_digit,
        pix_keys: pix_keys
      )
    end

    it "requires holder_type, holder_tax_id, branch_code, and account_number" do
      expect { described_class.new }.to raise_error(ArgumentError)

      expect {
        described_class.new(
          holder_tax_id: holder_tax_id,
          branch_code: branch_code,
          account_number: account_number
        )
      }.to raise_error(ArgumentError) # missing holder_type

      expect {
        described_class.new(
          holder_type: holder_type,
          branch_code: branch_code,
          account_number: account_number
        )
      }.to raise_error(ArgumentError) # missing holder_tax_id

      expect {
        described_class.new(
          holder_type: holder_type,
          holder_tax_id: holder_tax_id,
          account_number: account_number
        )
      }.to raise_error(ArgumentError) # missing branch_code

      expect {
        described_class.new(
          holder_type: holder_type,
          holder_tax_id: holder_tax_id,
          branch_code: branch_code
        )
      }.to raise_error(ArgumentError) # missing account_number

      expect {
        described_class.new(
          holder_type: holder_type,
          holder_tax_id: holder_tax_id,
          branch_code: branch_code,
          account_number: account_number
        )
      }.not_to raise_error
    end

    describe "#to_hash" do
      it "returns the API format" do
        expect(bank_account_info.to_hash).to eql(
          account_type: account_type,
          account_purpose: account_purpose,
          holder_type: holder_type,
          holder_tax_id: {type: "cpf", value: "12345678901"},
          country: country,
          ispb_code: ispb_code,
          branch_code: branch_code,
          account_number: account_number,
          account_check_digit: account_check_digit,
          pix_keys: [{type: "cpf", value: "12345678901"}, {type: "email", value: "human@being.com"}]
        )
      end
    end

    describe "readers" do
      it "exposes attribute readers" do
        expect(bank_account_info.account_type).to eq(account_type)
        expect(bank_account_info.account_purpose).to eq(account_purpose)
        expect(bank_account_info.holder_type).to eq(holder_type)
        expect(bank_account_info.holder_tax_id).to eq(holder_tax_id)
        expect(bank_account_info.country).to eq(country)
        expect(bank_account_info.ispb_code).to eq(ispb_code)
        expect(bank_account_info.branch_code).to eq(branch_code)
        expect(bank_account_info.account_number).to eq(account_number)
        expect(bank_account_info.account_check_digit).to eq(account_check_digit)
        expect(bank_account_info.pix_keys).to eql(pix_keys)
      end
    end
  end
end
