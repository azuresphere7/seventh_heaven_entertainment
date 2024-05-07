class TicketReservationBroadcaster
  include Rails.application.routes.url_helpers
  CHANNEL = "ticket_reservation_channel"

  attr_reader :event_id, :reservation_number, :channel
  private :event_id, :reservation_number, :channel

  def initialize(event_id:, reservation_number:, channel: CHANNEL)
    @channel = channel
    @reservation_number = reservation_number
    @event_id = event_id
  end

  def broadcast_expired
    ActionCable.server.broadcast(stream_name, {
      reservation_number: reservation_number,
      redirect_to: event_reservation_expire_path(event_id)
    })
  end

  def broadcast_activated
    ActionCable.server.broadcast(stream_name, {
      reservation_number: reservation_number,
      redirect_to: new_event_order_path(event_id)
    })
  end

  def stream_name
    "#{CHANNEL}_#{reservation_number}"
  end
end
