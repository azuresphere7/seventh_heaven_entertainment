require "rails_helper"

RSpec.describe OrderService do
  describe "#create_order" do
    let(:event) { create(:event) }

    it "creates an order for the event" do
      order = described_class.create({event: event, quantity: 2})
      expect(order).to be_persisted
        .and have_attributes(event: event, quantity: 2)
    end

    it "adds the order to the event queue" do
      order = described_class.create({event: event, quantity: 2})
      event_queue = EventQueue.find_by(event_id: event.id)
      expect(event_queue.queued_orders.find_by(order_id: order.id)).to be_present
    end
  end
end
