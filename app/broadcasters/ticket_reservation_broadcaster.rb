class TicketReservationBroadcaster
  include Rails.application.routes.url_helpers
  CHANNEL = "ticket_reservation_channel"

  attr_reader :event_id, :reservation_reference, :channel
  private :event_id, :reservation_reference, :channel

  def initialize(event_id:, reservation_reference:, channel: CHANNEL)
    @channel = channel
    @reservation_reference = reservation_reference
    @event_id = event_id
  end

  def broadcast_expired
    ActionCable.server.broadcast(stream_name, {
      reservation_reference: reservation_reference,
      redirect_to: expire_event_ticket_reservation_path(event_id, reservation_reference)
    })
  end

  def broadcast_activated
    ActionCable.server.broadcast(stream_name, {
      reservation_reference: reservation_reference,
      redirect_to: new_event_order_path(event_id)
    })
  end

  def stream_name
    "#{CHANNEL}_#{reservation_reference}"
  end
end
