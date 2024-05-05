require "rails_helper"

RSpec.describe ProcessTicketQueueJob do
  describe "#perform" do
    it "calls the TicketSaleService.process_ticket_queue with the event_id" do
      event_id = 1
      allow(TicketSaleService).to receive(:process_ticket_queue).with(event_id: event_id).and_return(nil)

      described_class.perform_now(event_id)

      expect(TicketSaleService).to have_received(:process_ticket_queue).with(event_id: event_id)
    end
  end
end
