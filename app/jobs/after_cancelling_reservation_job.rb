class AfterCancellingReservationJob < ApplicationJob
  queue_as :default

  def perform(reservation_reference)
    reservation = TicketReservation.find_by!(reference: reservation_reference)

    broadcast_reservation_cancelled(reservation)
  end

  private

  def broadcast_reservation_cancelled(reservation)
    TicketReservationBroadcaster.new(
      reservation_reference: reservation.reference,
      event_id: reservation.event_id
    ).broadcast_cancelled
  end
end
