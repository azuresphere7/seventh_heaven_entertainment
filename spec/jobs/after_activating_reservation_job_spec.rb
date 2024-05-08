require "rails_helper"

RSpec.describe AfterActivatingReservationJob do
  describe "#perform" do
    let(:reservation) { create(:ticket_reservation) }
    let(:expected_args) do
      {
        event_id: reservation.event_id,
        reservation_reference: reservation.reference
      }
    end
    let(:broadcaster_double) { instance_double(TicketReservationBroadcaster) }

    before do
      allow(TicketReservationBroadcaster).to receive(:new).and_return(broadcaster_double)
      allow(broadcaster_double).to receive(:broadcast_activated).and_return(nil)
    end

    it "calls the TicketReservationBroadcaster.broadcast_activated with the event_id and reservation_reference" do
      described_class.perform_now(reservation.reference)

      expect(TicketReservationBroadcaster).to have_received(:new).with(expected_args)
      expect(broadcaster_double).to have_received(:broadcast_activated)
    end

    it "schedules the reservation to expire" do
      allow(ExpireTicketReservationJob).to receive_messages(set: ExpireTicketReservationJob, perform_later: nil)

      described_class.perform_now(reservation.reference)

      expect(ExpireTicketReservationJob).to have_received(:set).with(wait_until: reservation.valid_until)
      expect(ExpireTicketReservationJob).to have_received(:perform_later).with(reservation.reference)
    end
  end
end
