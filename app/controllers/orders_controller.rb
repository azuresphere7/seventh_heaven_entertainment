class OrdersController < ApplicationController
  class NoReservationNumberError < StandardError; end

  before_action :set_event, only: %i[new create show]

  def show
    @order = Order.find(params[:id])
  end

  def new
    @ticket_reservation = TicketReservation.find_by!(reservation_number: reservation_number)
    @order = Order.new
    # TODO: remove prefilled data
    @order.build_customer_info(name: "test", email: "test@example", age: 18, gender: "female")

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("reservation_form", partial: "form", locals: {event: @event, order: @order})
      end
      format.html do
        render :new
      end
    end
  rescue ActiveRecord::RecordNotFound, NoReservationNumberError
    flash[:error] = "Reservation number not found in session."
    redirect_to root_path
  end

  def create
    TicketSaleService.order_tickets(
      event_id: @event.id,
      reservation_number: reservation_number,
      # reference: SecureRandom.uuid,
      customer_details: order_params[:customer_info_attributes].to_h
    )

    # @order = Order.find_by!(reference: reference)
    @order = Order.first

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("reservation_form", partial: "order", locals: {event: @event, order: @order})
      end
      format.html do
        redirect_to event_order_path(@event, @order)
      end
    end
  rescue
    # handle errors like invalid order, and reservation expired
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def order_params
    params.require(:order).permit(customer_info_attributes: [:name, :email, :age, :gender])
  end

  def reservation_number
    reservation_number = session[:reservation_number]
    return reservation_number unless reservation_number && Rails.cache.exist?(reservation_number)
    raise NoReservationNumberError unless reservation_number
  end
end
