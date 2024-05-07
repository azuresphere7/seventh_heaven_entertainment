class TicketReservationChannel < ApplicationCable::Channel
  def subscribed
    if params[:reservation_reference]
      stream_from "ticket_reservation_channel_#{params[:reservation_reference]}"
    else
      reject
    end
  end

  def unsubscribed
  end
end
