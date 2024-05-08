class ProcessTicketQueueJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    # simulate a delay in the reservation process for demo purposes
    sleep 3 if Rails.env.development?
    TicketSaleService.process_ticket_queue(event_id: event_id)
  rescue
  end
end
