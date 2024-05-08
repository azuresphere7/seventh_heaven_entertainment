require "rails_helper"

RSpec.describe Order do
  describe ".for_event" do
    let(:event) { create(:event) }
    let(:order) { create(:order, event: event) }

    before { create(:order) }

    it "returns the orders for the event" do
      expect(described_class.for_event(event)).to eq([order])
    end
  end

  describe "#total" do
    let(:order) { create(:order, quantity: 4, ticket_price: "21.00") }

    it "returns the total price of the order" do
      expect(order.total.to_s).to eql("84.0")
    end
  end

  describe "#quantity" do
    let(:order) { create(:order, quantity: 4) }

    it "is required" do
      order.quantity = nil
      expect(order).not_to be_valid
      expect(order.errors[:quantity]).to include("is not a number")
    end
  end

  describe "#ticket_price" do
    let(:order) { create(:order, ticket_price: "21.00") }

    it "is required" do
      order.ticket_price = nil
      expect(order).not_to be_valid
      expect(order.errors[:ticket_price]).to include("can't be blank")
    end
  end
end
