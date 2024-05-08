require "rails_helper"

RSpec.describe TicketReservation do
  describe ".enqueued" do
    let(:enqueued_reservation) { create(:ticket_reservation, status: :enqueued) }

    before { create(:ticket_reservation, status: :active) }

    it "returns only enqueued reservations" do
      expect(described_class.enqueued).to eq([enqueued_reservation])
    end
  end

  describe ".active" do
    let(:active_reservation) { create(:ticket_reservation, status: :active) }

    before { create(:ticket_reservation, status: :enqueued) }

    it "returns only active reservations" do
      expect(described_class.active).to eq([active_reservation])
    end
  end

  describe "#enqueue" do
    let(:ticket_sale) { create(:ticket_sale) }

    it "creates a new enqueued reservation" do
      ticket_reservation = ticket_sale.ticket_reservations.enqueue(quantity: 1, reference: "reference")
      expect(ticket_reservation).to be_enqueued
    end

    context "when called outside the scope of a ticket sale" do
      it "raises activerecord invalid" do
        expect { described_class.enqueue(quantity: 1, reference: "reference") }
          .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Ticket sale must exist")
      end
    end

    context "when quantity is blank" do
      it "raises activerecord invalid" do
        expect { ticket_sale.ticket_reservations.enqueue(quantity: "", reference: "reference") }
          .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Quantity is not a number")
      end
    end

    context "when there reference is blank" do
      it "raises activerecord invalid" do
        expect { ticket_sale.ticket_reservations.enqueue(quantity: 1, reference: "") }
          .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Reference can't be blank")
      end
    end
  end

  describe "#activate" do
    let(:ticket_reservation) { create(:ticket_reservation, status: :enqueued) }

    it "activates the reservation and sets the valid_until" do
      expect { ticket_reservation.activate }
        .to change(ticket_reservation, :status)
        .from("enqueued").to("active")
        .and change(ticket_reservation, :valid_until)
        .from(nil).to(be_within(10.seconds).of(8.minutes.from_now))
    end

    it "Enqueues a AfterActivatingReservationJob job" do
      expect { ticket_reservation.activate }
        .to have_enqueued_job(AfterActivatingReservationJob).with(ticket_reservation.reference)
    end

    context "when the reservation is not enqueued" do
      let(:ticket_reservation) { create(:ticket_reservation, status: :active) }

      it "raises an ActiveRecord RecordInvalid" do
        expect { ticket_reservation.activate }
          .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Status was not enqueued, status: active")
      end
    end
  end

  describe "#cancel_because_of_no_availability" do
    let(:ticket_reservation) { create(:ticket_reservation, status: :enqueued) }

    it "cancels the reservation" do
      expect { ticket_reservation.cancel_because_of_no_availability }
        .to change(ticket_reservation, :status).from("enqueued").to("no_availability")
    end

    it "enqueues the AfterCancellingReservationJob" do
      expect { ticket_reservation.cancel_because_of_no_availability }
        .to have_enqueued_job(AfterCancellingReservationJob).with(ticket_reservation.reference)
    end

    context "when the reservation is not enqueued" do
      let(:ticket_reservation) { create(:ticket_reservation, status: :active) }

      it "raises an ActiveRecord RecordInvalid" do
        expect { ticket_reservation.cancel_because_of_no_availability }
          .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Status was not enqueued, status: active")
      end
    end
  end

  describe "#expire" do
    let(:ticket_reservation) { create(:ticket_reservation, status: :active) }

    it "expires the reservation" do
      expect { ticket_reservation.expire }
        .to change(ticket_reservation, :status).from("active").to("expired")
    end

    it "enqueues a AfterExpiringReservationJob job" do
      expect { ticket_reservation.expire }
        .to have_enqueued_job(AfterExpiringReservationJob).with(ticket_reservation.reference)
    end

    context "when the reservation is not active" do
      let(:ticket_reservation) { create(:ticket_reservation, status: :enqueued) }

      it "raises an ActiveRecord RecordInvalid" do
        expect { ticket_reservation.expire }
          .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Status was not active, status: enqueued")
      end
    end
  end

  describe "#head_of_the_queue" do
    before do
      create(:ticket_reservation, status: :active, reference: "1")
      create(:ticket_reservation, status: :enqueued, reference: "2")
      create(:ticket_reservation, status: :enqueued, reference: "3")
    end

    it "returns the oldest enqueued reservation" do
      expected_reservation = described_class.find_by!(reference: "2")
      expect(described_class.head_of_the_queue).to eq(expected_reservation)
    end
  end

  describe "#can_expire?" do
    let(:ticket_reservation) { build(:ticket_reservation, status: :active, valid_until: 1.minute.ago) }

    it "returns true when the reservation is active and the valid_until is in the past" do
      expect(ticket_reservation).to be_can_expire
    end

    it "returns false when the reservation is not active" do
      ticket_reservation.status = :enqueued
      expect(ticket_reservation).not_to be_can_expire
    end

    it "returns false when the valid_until is in the future" do
      ticket_reservation.valid_until = 1.minute.from_now
      expect(ticket_reservation).not_to be_can_expire
    end
  end

  describe "#active?" do
    it "returns true when the status is active" do
      ticket_reservation = build(:ticket_reservation, status: :active)
      expect(ticket_reservation).to be_active
    end

    it "returns false when the status is not active" do
      ticket_reservation = build(:ticket_reservation, status: :enqueued)
      expect(ticket_reservation).not_to be_active
    end
  end

  describe "#enqueued?" do
    it "returns true when the status is enqueued" do
      ticket_reservation = build(:ticket_reservation, status: :enqueued)
      expect(ticket_reservation).to be_enqueued
    end

    it "returns false when the status is not enqueued" do
      ticket_reservation = build(:ticket_reservation, status: :active)
      expect(ticket_reservation).not_to be_enqueued
    end
  end

  describe "#ticket_price" do
    it "returns the price of its ticket sale event" do
      ticket_sale = create(:ticket_sale, event: build(:event, price: 10))
      ticket_reservation = build(:ticket_reservation, ticket_sale: ticket_sale)
      expect(ticket_reservation.ticket_price).to eq(10)
    end
  end

  describe "#total_price" do
    it "returns the quantity times the ticket price" do
      ticket_sale = create(:ticket_sale, event: build(:event, price: 10))
      ticket_reservation = build(:ticket_reservation, ticket_sale: ticket_sale, quantity: 2)
      expect(ticket_reservation.total_price).to eq(20)
    end
  end

  describe "#quantity" do
    it "is required" do
      ticket_reservation = build(:ticket_reservation, quantity: nil)
      ticket_reservation.valid?
      expect(ticket_reservation.errors.messages[:quantity]).to include("is not a number")
    end

    it "is greater than 0" do
      ticket_reservation = build(:ticket_reservation, quantity: 0)
      ticket_reservation.valid?
      expect(ticket_reservation.errors.messages[:quantity]).to include("must be greater than 0")
    end

    it "is less than 7" do
      ticket_reservation = build(:ticket_reservation, quantity: 7)
      ticket_reservation.valid?
      expect(ticket_reservation.errors.messages[:quantity]).to include("must be less than 7")
    end
  end

  describe "#status" do
    it "is required" do
      ticket_reservation = build(:ticket_reservation, status: nil)
      ticket_reservation.valid?
      expect(ticket_reservation.errors.messages[:status]).to include("can't be blank")
    end

    it "is in the list of statuses" do
      ticket_reservation = build(:ticket_reservation, status: "invalid")
      ticket_reservation.valid?
      expect(ticket_reservation.errors.messages[:status]).to include("is not included in the list")
    end
  end

  describe "#reference" do
    it "is required" do
      ticket_reservation = build(:ticket_reservation, reference: nil)
      ticket_reservation.valid?
      expect(ticket_reservation.errors.messages[:reference]).to include("can't be blank")
    end
  end

  describe "#to_param" do
    it "returns the reference" do
      ticket_reservation = build(:ticket_reservation, reference: "reference")
      expect(ticket_reservation.to_param).to eq("reference")
    end
  end
end
