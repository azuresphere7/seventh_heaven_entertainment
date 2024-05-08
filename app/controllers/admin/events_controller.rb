module Admin
  class EventsController < ApplicationController
    before_action :set_event, only: %i[show edit update]

    # TODO: scope on user when authenticated
    def index
      @events = Event.all
    end

    def show
    end

    def new
      @event = Event.new
    end

    def edit
    end

    def create
      @event = Event.new(event_create_params)

      respond_to do |format|
        if @event.save
          format.html { redirect_to admin_event_url(@event), notice: I18n.t("event.created") }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @event.update(event_update_params)
          format.html { redirect_to admin_event_url(@event), I18n.t("event.updated") }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    private

    def set_event
      @event = Event.find(params[:id])
    end

    def event_create_params
      params.require(:event).permit(:title, :price, :starts_on, :ends_on, :location, :capacity, :description)
    end

    def event_update_params
      params.require(:event).permit(:title, :description)
    end
  end
end
