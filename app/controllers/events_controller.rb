class EventsController < ApplicationController
  def index
    @events = Event.with_open_ticket_sale
  end
end
