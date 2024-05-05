require "rails_helper"

RSpec.describe TicketSaleService do
  describe "#reserve_tickets" do
    let(:event) { create(:event) }
    let(:reservation_number) { SecureRandom.uuid }
    let(:ticket_sale) { TicketSale.find_by(event_id: event.id) }

    it "queues a ticket reservation to the sale" do
      described_class.reserve_tickets(event_id: event.id, quantity: 1, reservation_number: reservation_number)
      expect(ticket_sale.ticket_reservations.first).to have_attributes(
        quantity: 1,
        reservation_number: reservation_number,
        status: "enqueued"
      )
    end

    context "when the reservation is at the head of the queue" do
      before { allow(ProcessTicketQueueJob).to receive(:perform_later).and_return(nil) }

      it "enqueues a job to process the ticket queue" do
        described_class.reserve_tickets(event_id: event.id, quantity: 1, reservation_number: reservation_number)
        expect(ProcessTicketQueueJob).to have_received(:perform_later)
      end
    end

    context "when the reservation is not at the head of the queue" do
      before do
        described_class.reserve_tickets(event_id: event.id, quantity: 1)
        allow(ProcessTicketQueueJob).to receive(:perform_later).and_return(nil)
      end

      it "does not process the ticket queue" do
        described_class.reserve_tickets(event_id: event.id, quantity: 1, reservation_number: reservation_number)
        expect(ProcessTicketQueueJob).not_to have_received(:perform_later)
      end
    end
  end

  describe "#order_tickets" do
    let(:service) { described_class }
    let(:event) { create(:event, capacity: 1) }
    let(:reservation_number) { SecureRandom.uuid }
    let(:ticket_sale) { TicketSale.find_by(event_id: event.id) }
    let(:customer_details) do
      {
        name: "John Doe",
        email: "john.doe@gmail.com",
        age: 18,
        gender: "male"
      }
    end

    before do
      service.reserve_tickets(event_id: event.id, quantity: 1, reservation_number: reservation_number)
      service.process_ticket_queue(event_id: event.id)
    end

    it "creates an order for the reservation" do
      service.order_tickets(event_id: event.id, reservation_number: reservation_number, customer_details: customer_details)
      expect(Order.first)
        .to be_present
        .and have_attributes(
          event_id: event.id,
          quantity: 1
        )
    end

    it "adds the customer info to the order" do
      service.order_tickets(event_id: event.id, reservation_number: reservation_number, customer_details: customer_details)
      expect(Order.first.customer_info).to have_attributes(customer_details)
    end

    context "when the reservation is not active" do
      before do
        TicketReservation.first.update!(status: "expired")
      end

      it "does not create an order" do
        expect do
          service.order_tickets(event_id: event.id, reservation_number: reservation_number, customer_details: customer_details)
        end.to raise_error(TicketSale::InvalidReservation)

        expect(Order.count).to eq(0)
      end
    end
  end

  describe "#expire_reservation" do
    let(:service) { described_class }
    let(:event) { create(:event, capacity: 1) }
    let(:reservation_number) { SecureRandom.uuid }
    let(:ticket_sale) { TicketSale.find_by(event_id: event.id) }

    before do
      service.reserve_tickets(event_id: event.id, quantity: 1, reservation_number: reservation_number)
      service.process_ticket_queue(event_id: event.id)
    end

    context "when the reservation is active and valid_until is in the past" do
      it "expires the reservation" do
        Timecop.travel(8.minutes.from_now) do
          expect do
            service.expire_reservation(event_id: event.id, reservation_number: reservation_number)
          end.to change { TicketReservation.first.status }.from("active").to("expired")
        end
      end
    end

    # context "when the valid_until is in the future" do
    #   it "does not expire the reservation" do
    #     service.expire_reservation(event_id: event.id, reservation_number: reservation_number)
    #     expect(TicketReservation.first.status).to eq("active")
    #   end
    # end

    # context "when the reservation is not active" do
    #   before do
    #     TicketReservation.first.update!(status: "no_availability")
    #   end

    #   it "does not expire the reservation" do
    #     service.expire_reservation(event_id: event.id, reservation_number: reservation_number)
    #     expect(TicketReservation.first.status).to eq("no_availability")
    #   end
    # end
  end

  describe "#process_ticket_queue" do
    let(:service) { described_class }
    let(:event) { create(:event, capacity: 2) }
    let(:reservation_number) { SecureRandom.uuid }
    let(:ticket_sale) { TicketSale.find_by(event_id: event.id) }

    before do
      service.reserve_tickets(event_id: event.id, quantity: 2, reservation_number: reservation_number)
    end

    it "processes the ticket queue" do
      service.process_ticket_queue(event_id: event.id)
      expect(TicketReservation.find_by(reservation_number: reservation_number).status).to eq("active")
    end
  end
end
