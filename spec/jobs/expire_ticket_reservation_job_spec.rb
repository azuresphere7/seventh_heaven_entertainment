require "rails_helper"

RSpec.describe ExpireTicketReservationJob do
  describe "#perform" do
    let(:reservation) { create(:ticket_reservation) }
    let(:expected_args) do
      {
        event_id: reservation.event_id,
        reference: reservation.reference
      }
    end

    it "calls the TicketSaleService.expire_reservation with the event_id and reservation_reference" do
      allow(TicketSaleService)
        .to receive(:expire_reservation)
        .with(expected_args).and_return(nil)

      described_class.perform_now(reservation.reference)

      expect(TicketSaleService).to have_received(:expire_reservation).with(expected_args)
    end
  end
end
