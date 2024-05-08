require "rails_helper"

RSpec.describe TicketReservationBroadcaster do
  let(:event_id) { 1 }
  let(:reservation_reference) { "123" }
  let(:channel) { "ticket_reservation_channel" }
  let(:broadcaster) { described_class.new(event_id: event_id, reservation_reference: reservation_reference, channel: channel) }

  before { allow(ActionCable.server).to receive(:broadcast).and_return(true) }

  describe "#broadcast_activated" do
    it "broadcasts the reservation reference and the redirect path to the new event order path" do
      broadcaster.broadcast_activated

      expect(ActionCable.server).to have_received(:broadcast).with("#{channel}_#{reservation_reference}", {
        reservation_reference: reservation_reference,
        redirect_to: "/events/1/orders/new"
      })
    end
  end

  describe "#broadcast_expired" do
    it "broadcasts the reservation reference and the redirect path to the event reservation expire path" do
      broadcaster.broadcast_expired

      expect(ActionCable.server).to have_received(:broadcast).with("#{channel}_#{reservation_reference}", {
        reservation_reference: reservation_reference,
        redirect_to: "/events/1/ticket_reservations/123/expire"
      })
    end
  end

  describe "#broadcast_cancelled" do
    it "broadcasts the reservation reference and the redirect path to the event reservation cancel path" do
      broadcaster.broadcast_cancelled

      expect(ActionCable.server).to have_received(:broadcast).with("#{channel}_#{reservation_reference}", {
        reservation_reference: reservation_reference,
        redirect_to: "/events/1/ticket_reservations/123/cancel"
      })
    end
  end
end
