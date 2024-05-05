class ExpireTicketReservationJob < ApplicationJob
  queue_as :default

  def perform(reservation_number)
    reservation = TicketReservation.find_by!(reservation_number: reservation_number)
    TicketSaleService.expire_reservation(
      event_id: reservation.event_id,
      reservation_number: reservation.reservation_number
    )
  end
end
