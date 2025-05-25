// app/javascript/controllers/navbar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["burger", "menu"]

  connect() {
    // Se asegura de que todo esté conectado correctamente
    console.log("Navbar controller connected")
  }

  toggle() {
    this.burgerTarget.classList.toggle("is-active")
    this.menuTarget.classList.toggle("is-active")
  }
}
