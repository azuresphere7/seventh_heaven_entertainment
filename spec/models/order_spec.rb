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
end
