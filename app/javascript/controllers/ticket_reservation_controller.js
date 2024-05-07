// app/javascript/controllers/connect_to_channel_controller.js

import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer";

export default class extends Controller {
  connect() {
    console.log('ConnectToChannel controller connected')
    const reservationNumber = this.data.get("reservationNumber");
    if (reservationNumber) {
      this.connectToChannel(reservationNumber);
    }
  }

  connectToChannel(reservationNumber) {
    consumer.subscriptions.create(
      { channel: "TicketReservationChannel", reservation_reference: reservationNumber },
      {
        connected() {
          console.log("Connected to TicketReservationChannel");
        },
        disconnected() {
          console.log("Disconnected from TicketReservationChannel");
        },
        received(data) {
          console.log('Received TicketReservationChannel')
          if (data.redirect_to) { Turbo.visit(data.redirect_to);}
        },
      }
    );
  }
}