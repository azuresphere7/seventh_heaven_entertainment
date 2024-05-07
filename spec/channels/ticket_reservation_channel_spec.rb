# spec/channels/ticket_reservation_channel_spec.rb

require "rails_helper"

RSpec.describe TicketReservationChannel do
  let(:reservation_number) { "test_reservation_number" }

  before do
    # Stubbing Action Cable's subscription identifier with the reservation number
    stub_connection(params: {reservation_number: reservation_number})
  end

  it "successfully subscribes to the channel with reservation number" do
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("ticket_reservation_channel_#{reservation_number}")
  end

  it "does not subscribe to the channel if reservation number is not provided" do
    # Stubbing connection without reservation number
    stub_connection(params: {})

    subscribe
    expect(subscription).to be_rejected
  end
end
