import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => this.close(), 5000)
  }

  close() {
    clearTimeout(this.timeout)
    this.element.classList.remove('animate__slideInRight')
    this.element.classList.add('animate__animated', 'animate__slideOutRight')
    setTimeout(() => this.element.remove(), 500)
  }
}