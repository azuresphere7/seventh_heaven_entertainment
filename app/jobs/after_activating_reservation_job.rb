class AfterActivatingReservationJob < ApplicationJob
  queue_as :default

  def perform(reservation_reference)
    reservation = TicketReservation.find_by!(reference: reservation_reference)

    schedule_expiring_reservation(reservation)
    broadcast_reservation_activated(reservation)
  end

  private

  def broadcast_reservation_activated(reservation)
    TicketReservationBroadcaster.new(
      reservation_reference: reservation.reference,
      event_id: reservation.event_id
    ).broadcast_activated
  end

  def schedule_expiring_reservation(reservation)
    ExpireTicketReservationJob
      .set(wait_until: reservation.valid_until)
      .perform_later(reservation.reference)
  end
end
