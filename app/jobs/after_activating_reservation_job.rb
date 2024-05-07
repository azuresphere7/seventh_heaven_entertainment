class AfterActivatingReservationJob < ApplicationJob
  queue_as :default

  def perform(reservation_number)
    reservation = TicketReservation.find_by!(reservation_number: reservation_number)

    schedule_expiring_reservation(reservation)
    broadcast_reservation_activated(reservation)
  rescue => e
    Rails.logger.debug e.message
    debugger
  end

  private

  def broadcast_reservation_activated(reservation)
    TicketReservationBroadcaster.new(
      reservation_number: reservation.reservation_number,
      event_id: reservation.event_id
    ).broadcast_activated
  end

  def schedule_expiring_reservation(reservation)
    ExpireTicketReservationJob
      .set(wait_until: reservation.valid_until)
      .perform_later(reservation.reservation_number)
  end
end
