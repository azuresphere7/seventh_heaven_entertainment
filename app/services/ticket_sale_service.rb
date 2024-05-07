module TicketSaleService
  def self.reserve_tickets(event_id:, quantity:, reservation_number: SecureRandom.uuid)
    ticket_sale = TicketSale.find_by!(event_id: event_id)
    ticket_sale.queue_reservation(quantity:, reservation_number:)

    return unless ticket_sale.reservation_at_head_of_the_queue?(
      reservation_number: reservation_number
    )

    ProcessTicketQueueJob.perform_later(event_id)
  end

  def self.order_tickets(event_id:, reservation_number:, customer_details:)
    TicketSale.transaction do
      ticket_sale = TicketSale.find_by!(event_id: event_id)
      ticket_sale.submit_order(reservation_number: reservation_number, customer_details: customer_details)
    end

    # ActionCable.server.broadcast("ticket_reservation_channel", {
    #   reservation_number: reservation_number,
    #   status: "order_submitted"
    # })
  end

  def self.expire_reservation(event_id:, reservation_number:)
    TicketSale.transaction do
      ticket_sale = TicketSale.find_by!(event_id: event_id)
      ticket_sale.expire_reservation(reservation_number: reservation_number)
    end

    # AfterExpiringReservationJob.perform_later(event_id)

    ActionCable.server.broadcast("ticket_reservation_channel", {
      reservation_number: reservation_number,
      status: "reservation_expired"
    })

    ProcessTicketQueueJob.perform_later(event_id)
  end

  # we are locking the queue to prevent race conditions from happening
  def self.process_ticket_queue(event_id:)
    TicketSale.transaction do
      ticket_sale = TicketSale.find_by!(event_id: event_id).lock!
      ticket_sale.process_queue
    end
  end
end
