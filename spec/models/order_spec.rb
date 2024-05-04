require "rails_helper"

RSpec.describe Order do
  describe "#quantity" do
    it "is required" do
      order = build(:order, quantity: nil)
      order.valid?
      expect(order.errors.messages[:quantity]).to include("can't be blank")
    end

    it "is greater than 0" do
      order = build(:order, quantity: 0)
      order.valid?
      expect(order.errors.messages[:quantity]).to include("must be greater than 0")
    end

    it "is less than 7" do
      order = build(:order, quantity: 7)
      order.valid?
      expect(order.errors.messages[:quantity]).to include("must be less than 7")
    end
  end
end
