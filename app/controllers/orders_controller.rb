class OrdersController < ApplicationController
  class NoReservationNumberError < StandardError; end

  before_action :set_event, only: %i[new create show]

  def show
    @order = Order.find(params[:id])
  end

  def new
    @ticket_reservation = TicketReservation.find_by!(reference: reservation_reference)
    @order = Order.new
    @order.build_customer_info

    respond_to do |format|
      format.html do
        render :new
      end
    end
  rescue ActiveRecord::RecordNotFound, NoReservationNumberError
    flash[:error] = I18n.t("errors.reservation.expired")
    redirect_to expire_event_ticket_reservation_path(@event, reservation_reference)
  end

  def create
    TicketSaleService.order_tickets(
      event_id: @event.id,
      reference: reservation_reference,
      customer_details: order_params[:customer_info_attributes].to_h
    )

    @order = Order.find_by!(reference: reservation_reference)

    respond_to do |format|
      format.html do
        redirect_to event_order_path(@event, @order)
      end
    end
    # rescue
    # handle errors like invalid order, and reservation expired
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def order_params
    params.require(:order).permit(customer_info_attributes: [:name, :email, :age, :gender])
  end

  def reservation_reference
    @reservation_reference ||= begin
      reservation_reference = session[:reservation_reference]
      return reservation_reference unless reservation_reference && Rails.cache.exist?(reservation_reference)
      raise NoReservationNumberError unless reservation_reference
    end
  end
end
