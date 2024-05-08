class AfterExpiringReservationJob < ApplicationJob
  queue_as :default

  def perform(reservation_reference)
    reservation = TicketReservation.find_by!(reference: reservation_reference)
    broadcast_reservation_expired(reservation)
  end

  private

  def broadcast_reservation_expired(reservation)
    TicketReservationBroadcaster.new(
      reservation_reference: reservation.reference,
      event_id: reservation.event_id
    ).broadcast_expired
  end
end
