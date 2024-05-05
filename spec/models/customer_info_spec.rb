require "rails_helper"

RSpec.describe CustomerInfo do
  describe "#order" do
    it "requires an order to be present" do
      customer_info = build(:customer_info, order: nil)
      customer_info.valid?
      expect(customer_info.errors[:order]).to include("must exist")
    end
  end

  describe "#name" do
    it "requires a name to be present" do
      customer_info = build(:customer_info, name: nil)
      customer_info.valid?
      expect(customer_info.errors[:name]).to include("can't be blank")
    end
  end

  describe "#email" do
    it "requires an email to be present" do
      customer_info = build(:customer_info, email: nil)
      customer_info.valid?
      expect(customer_info.errors[:email]).to include("can't be blank")
    end

    it "requires an email to be in the correct format" do
      customer_info = build(:customer_info, email: "invalid-email")
      customer_info.valid?
      expect(customer_info.errors[:email]).to include("is invalid")
    end
  end

  describe "#gender" do
    it "requires a gender to be present" do
      customer_info = build(:customer_info, gender: nil)
      customer_info.valid?
      expect(customer_info.errors[:gender]).to include("can't be blank")
    end

    it "requires inclusion in the list of gender options" do
      customer_info = build(:customer_info, gender: "invalid")
      customer_info.valid?
      expect(customer_info.errors[:gender]).to include("is not included in the list")
    end
  end
end
