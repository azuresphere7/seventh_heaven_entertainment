class TicketReservationsController < ApplicationController
  before_action :set_event, only: %i[new create show]

  def show
    @ticket_reservation = TicketReservation.find_by!(reservation_number: params[:reservation_number])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("reservation_form", partial: "ticket_reservation", locals: {event: @event, ticket_reservation: @ticket_reservation})
      end
      format.html do
        render :show
      end
    end
  end

  def new
    @ticket_reservation = TicketReservation.new

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("reservation_form", partial: "form", locals: {event: @event, ticket_reservation: @ticket_reservation})
      end
      format.html do
        render :new
      end
    end
  end

  def create
    reservation_number = SecureRandom.uuid

    TicketSaleService.reserve_tickets(
      event_id: params[:event_id],
      quantity: reservation_params[:quantity],
      reservation_number: reservation_number
    )
    @ticket_reservation = TicketReservation.find_by!(reservation_number: reservation_number)
    add_reservation_number_to_session

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("reservation_form", partial: "ticket_reservation", locals: {ticket_reservation: @ticket_reservation})
      end
      format.html do
        redirect_to event_ticket_reservation_path(@event, @ticket_reservation)
      end
    end
  rescue => e
    raise e
    # TODO: handle errors from ticketsaleservice, like sold out or invalid quantity
  end

  private

  # TODO: implement expire reservation
  def add_reservation_number_to_session
    Rails.cache.write(@ticket_reservation.reservation_number, true, expires_in: 1.hour)
    session[:reservation_number] = @ticket_reservation.reservation_number
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def reservation_params
    params.require(:ticket_reservation).permit(:quantity)
  end
end
