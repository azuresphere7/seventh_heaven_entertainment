class OrdersController < ApplicationController
  def reserve
    # TODO:  load spinner
    TicketSaleService.reserve_tickets(order_params)

    respond_to do |format|
      format.html { redirect_to events_path, notice: "Order was successfully created." }
      # format.html { redirect_to @order, notice: "Order was successfully created." }
      format.json { render :show, status: :created, location: @order }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: e.record.errors, status: :unprocessable_entity }
    end
  end

  def order_params
    params.require(:order).permit(:quantity, :event_id)
  end
end
