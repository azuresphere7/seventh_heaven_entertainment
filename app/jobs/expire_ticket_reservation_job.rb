class ExpireTicketReservationJob < ApplicationJob
  queue_as :default

  def perform(reference)
    reservation = TicketReservation.find_by!(reference: reference)

    TicketSaleService.expire_reservation(
      event_id: reservation.event_id,
      reference: reservation.reference
    )
  rescue
  end
end
