import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    console.log("notification controller connected")
    this.index = 0
    this.showNext()
  }

  showNext() {
    if (this.index >= this.messageTargets.length) return

    const element = this.messageTargets[this.index]
    element.classList.remove('is-hidden')
    element.classList.add('animate__slideInRight')

    setTimeout(() => {
      this.close(element)

      setTimeout(() => {
        this.index++
        this.showNext()
      }, 1000)
    }, 4500)
  }

  close(element) {
    element.classList.remove('animate__slideInRight')
    element.classList.add('animate__slideOutRight')

    setTimeout(() => {
      element.classList.add('is-hidden')
      element.classList.remove('animate__slideOutRight')
    }, 500)
  }

  closeNow(event) {
    const element = event.currentTarget.closest('.notification')
    this.close(element)
  }
}
