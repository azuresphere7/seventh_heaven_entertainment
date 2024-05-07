module TicketSaleService
  def self.reserve_tickets(event_id:, quantity:, reference:)
    ticket_sale = TicketSale.find_by!(event_id: event_id)
    ticket_sale.queue_reservation(quantity:, reference:)

    return unless ticket_sale.reservation_at_head_of_the_queue?(reference: reference)

    ProcessTicketQueueJob.perform_later(event_id)
  end

  def self.order_tickets(event_id:, reference:, customer_details:)
    TicketSale
      .find_by!(event_id: event_id)
      .submit_order(reference: reference, customer_details: customer_details)
  end

  def self.expire_reservation(event_id:, reference:)
    TicketSale
      .find_by!(event_id: event_id)
      .expire_reservation(reference: reference)

    # AfterExpiringReservationJob.perform_later(event_id)

    # ActionCable.server.broadcast("ticket_reservation_channel", {
    #   reference: reference,
    #   status: "reservation_expired"
    # })

    # ProcessTicketQueueJob.perform_later(event_id)
  end

  # we are locking the queue to prevent race conditions from happening
  def self.process_ticket_queue(event_id:)
    TicketSale
      .find_by!(event_id: event_id)
      .process_queue
  end
end
