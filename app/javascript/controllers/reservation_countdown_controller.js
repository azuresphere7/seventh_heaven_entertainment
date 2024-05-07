
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("ReservationCountdown controller connected")
    const validUntilSpan = this.element.querySelector("#valid-until");
    const validUntil = new Date(validUntilSpan.innerText).getTime();

    function updateTimer() {
      const now = new Date().getTime();
      
      const distance = validUntil - now;

      const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((distance % (1000 * 60)) / 1000);

      validUntilSpan.innerText = minutes + "m " + seconds + "s";

      if (distance < 0) {
        clearInterval(timer);
        validUntilSpan.innerText = "Expired";
        // Redirect to "/expire" when reservation expires
        // Turbo.visit("/expire");
      }
    }

    // Initial call to update timer
    updateTimer();

    // Update timer every second
    const timer = setInterval(updateTimer, 1000);
  }
}