require "rails_helper"

RSpec.describe TicketReservation do
  describe "#quantity" do
    it "is required" do
      ticket_reservation = build(:ticket_reservation, quantity: nil)
      ticket_reservation.valid?
      expect(ticket_reservation.errors.messages[:quantity]).to include("can't be blank")
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
end
