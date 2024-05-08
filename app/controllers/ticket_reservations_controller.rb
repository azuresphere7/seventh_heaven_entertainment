class TicketReservationsController < ApplicationController
  before_action :set_event, only: %i[new create show]

  def show
    @ticket_reservation = TicketReservation.find_by!(reference: params[:reservation_reference])

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
    reservation_reference = SecureRandom.uuid

    TicketSaleService.reserve_tickets(
      event_id: params[:event_id],
      quantity: reservation_params[:quantity],
      reference: reservation_reference
    )
    @ticket_reservation = TicketReservation.find_by!(reference: reservation_reference)
    add_reservation_reference_to_session

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("reservation_form", partial: "ticket_reservation", locals: {ticket_reservation: @ticket_reservation})
      end
      format.html do
        redirect_to event_ticket_reservation_path(@event, @ticket_reservation)
      end
    end
    # rescue => e
    #   TODO: handle errors from ticketsaleservice, like invalid quantity
  end

  private

  # TODO: implement expire reservation
  def add_reservation_reference_to_session
    Rails.cache.write(@ticket_reservation.reference, true, expires_in: 1.hour)
    session[:reservation_reference] = @ticket_reservation.reference
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def reservation_params
    params.require(:ticket_reservation).permit(:quantity)
  end
end
