class TicketReservationChannel < ApplicationCable::Channel
  def subscribed
    if params[:reservation_number]
      stream_from "ticket_reservation_channel_#{params[:reservation_number]}"
    end
  end

  def unsubscribed
  end
end
