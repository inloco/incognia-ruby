require "spec_helper"

module Incognia
  RSpec.describe BankAccount do
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
    let(:required_attrs) do
      {
        holder_type:    holder_type,
        holder_tax_id:  holder_tax_id,
        branch_code:    branch_code,
        account_number: account_number
      }
    end

    subject(:bank_account) do
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

    it "raises error when no required kwargs are provided" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it "requires holder_type" do
      expect { described_class.new(**required_attrs.except(:holder_type)) }.to raise_error(ArgumentError)
    end

    it "requires holder_tax_id" do
      expect { described_class.new(**required_attrs.except(:holder_tax_id)) }.to raise_error(ArgumentError)
    end

    it "requires branch_code" do
      expect { described_class.new(**required_attrs.except(:branch_code)) }.to raise_error(ArgumentError)
    end

    it "requires account_number" do
      expect { described_class.new(**required_attrs.except(:account_number)) }.to raise_error(ArgumentError)
    end

    it "does not raise error when all required kwargs are provided" do
      expect { described_class.new(**required_attrs) }.not_to raise_error
    end

    describe "#to_hash" do
      context "with only required fields" do
        subject(:only_required) { described_class.new(**required_attrs) }

        it "returns required fields (optional fields omitted)" do
          h = only_required.to_hash
          expect(h).to include(
            holder_type:    holder_type,
            holder_tax_id:  holder_tax_id.to_hash,
            branch_code:    branch_code,
            account_number: account_number
          )
          expect(h).not_to include(:account_type, :account_purpose, :country, :ispb_code, :account_check_digit, :pix_keys)
        end
      end

      context "when informing optional fields" do
        it "returns the API format with all fields" do
          expect(bank_account.to_hash).to eql(
            account_type:        account_type,
            account_purpose:     account_purpose,
            holder_type:         holder_type,
            holder_tax_id:       holder_tax_id.to_hash,
            country:             country,
            ispb_code:           ispb_code,
            branch_code:         branch_code,
            account_number:      account_number,
            account_check_digit: account_check_digit,
            pix_keys:            pix_keys.map(&:to_hash)
          )
        end
      end

      context "when holder_tax_id is not a PersonId nor a Hash" do
        it "keeps the value unchanged" do
          raw_id  = "12345678901"
          account = described_class.new(**required_attrs.merge(holder_tax_id: raw_id))
          expect(account.to_hash[:holder_tax_id]).to eq(raw_id)
        end
      end

      context "when pix_keys do not contain PixKey nor Hash items" do
        it "keeps the items unchanged" do
          raw_keys = ["a", :b, 123]
          account  = described_class.new(**required_attrs.merge(pix_keys: raw_keys))
          expect(account.to_hash[:pix_keys]).to eq(raw_keys)
        end
      end
    end

    describe "readers" do
      it "exposes attribute readers" do
        expect(bank_account.account_type).to eq(account_type)
        expect(bank_account.account_purpose).to eq(account_purpose)
        expect(bank_account.holder_type).to eq(holder_type)
        expect(bank_account.holder_tax_id).to eq(holder_tax_id)
        expect(bank_account.country).to eq(country)
        expect(bank_account.ispb_code).to eq(ispb_code)
        expect(bank_account.branch_code).to eq(branch_code)
        expect(bank_account.account_number).to eq(account_number)
        expect(bank_account.account_check_digit).to eq(account_check_digit)
        expect(bank_account.pix_keys).to eql(pix_keys)
      end
    end
  end
end
