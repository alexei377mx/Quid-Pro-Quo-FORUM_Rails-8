import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    siteKey: String,
    action: String,
    v2: Boolean
  }

  connect() {
    console.log("recaptcha controller connected")
    const submitBtn = this.element.querySelector("button[type='submit']")
    if (!submitBtn) {
      console.warn("[reCAPTCHA] Submit button not found in the form.")
      return
    }

    console.log(`[reCAPTCHA] Starting protection (${this.v2Value ? 'v2' : 'v3'}) for action: ${this.actionValue}`)

    submitBtn.classList.add("is-loading")
    submitBtn.disabled = true

    if (this.v2Value) {
      this.waitForRecaptchaV2(submitBtn)
    } else {
      this.executeRecaptchaV3(submitBtn)
    }
  }

  waitForRecaptchaV2(button) {
    console.log("[reCAPTCHA v2] Waiting for grecaptcha to become available...")
    const interval = setInterval(() => {
      if (window.grecaptcha) {
        clearInterval(interval)
        console.log("[reCAPTCHA v2] grecaptcha is ready. Enabling button.")
        button.classList.remove("is-loading")
        button.disabled = false
      }
    }, 100)

    setTimeout(() => {
      if (button.disabled) {
        clearInterval(interval)
        console.warn("[reCAPTCHA v2] Timeout reached. grecaptcha did not load.")
      }
    }, 10000)
  }

  executeRecaptchaV3(button) {
    if (!window.grecaptcha) {
      console.warn("[reCAPTCHA v3] grecaptcha is not yet available.")
      return
    }

    console.log("[reCAPTCHA v3] Executing reCAPTCHA...")
    grecaptcha.ready(() => {
      grecaptcha.execute(this.siteKeyValue, { action: this.actionValue }).then(token => {
        console.log("[reCAPTCHA v3] Token received. Inserting into form.")
        const input = document.createElement("input")
        input.type = "hidden"
        input.name = "g-recaptcha-response"
        input.value = token
        this.element.appendChild(input)

        console.log("[reCAPTCHA v3] grecaptcha is ready. Enabling button.")
        button.classList.remove("is-loading")
        button.disabled = false
      }).catch(error => {
        console.error("[reCAPTCHA v3] Error executing reCAPTCHA:", error)
      })
    })
  }
}
