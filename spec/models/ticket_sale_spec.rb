require "rails_helper"

RSpec.describe TicketSale do
  describe "#process" do
    context "when there are available tickets" do
      let(:reference) { SecureRandom.uuid }
      let(:ticket_sale) { create(:ticket_sale, capacity: 1) }

      before do
        ticket_sale.queue_reservation(quantity: 1, reference: reference)
      end

      it "activates the reservation" do
        ticket_sale.process_queue
        reservation = TicketReservation.find_by(reference: reference)
        expect(reservation).to have_attributes(
          status: "active",
          valid_until: be_within(10.seconds).of(8.minutes.from_now)
        )
      end
    end

    context "when there are not enough available tickets, but there are tickets reserved" do
      let(:ticket_sale) { create(:ticket_sale, capacity: 2) }
      let(:reference) { "reference" }
      let(:another_reference) { "another_reference" }

      before do
        ticket_sale.queue_reservation(quantity: 1, reference: SecureRandom.uuid)
        ticket_sale.queue_reservation(quantity: 2, reference: reference)
        ticket_sale.queue_reservation(quantity: 1, reference: another_reference)
      end

      it "does not activate the reservation and skips the next reservation" do
        reservation = TicketReservation.find_by(reference: reference)
        another_reservation = TicketReservation.find_by(reference: another_reference)

        expect { ticket_sale.process_queue }
          .to not_change { reservation.reload.status }.from("enqueued")
          .and not_change { another_reservation.reload.status }.from("enqueued")
      end
    end

    context "when the number of unsold tickets is less then the quantity of the reservation" do
      let(:ticket_sale) { create(:ticket_sale, capacity: 2) }
      let(:reference) { SecureRandom.uuid }
      let(:another_reference) { SecureRandom.uuid }

      before do
        ticket_sale.queue_reservation(quantity: 1, reference: SecureRandom.uuid)
        ticket_sale.queue_reservation(quantity: 3, reference: reference)
        ticket_sale.queue_reservation(quantity: 1, reference: another_reference)
      end

      it "cancels the first reservation, and activates the next reservation where the quantity can be met" do
        reservation = TicketReservation.find_by(reference: reference)
        another_reservation = TicketReservation.find_by(reference: another_reference)

        expect { ticket_sale.process_queue }
          .to change { reservation.reload.status }
          .from("enqueued").to("no_availability")
          .and change { another_reservation.reload.status }
          .from("enqueued").to("active")
      end
    end
  end

  describe "#queue_reservation" do
    let(:reference) { SecureRandom.uuid }

    it "adds a reservation to the ticket queue" do
      ticket_sale = create(:ticket_sale)
      ticket_sale.queue_reservation(quantity: 1, reference: reference)

      expect(ticket_sale.ticket_reservations.first).to have_attributes(
        quantity: 1,
        reference: reference,
        status: "enqueued"
      )
    end
  end
end
