class ProcessTicketQueueJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    TicketSaleService.process_ticket_queue(event_id: event_id)
  end
end
