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
      console.warn("[reCAPTCHA] Botón de envío no encontrado en el formulario.")
      return
    }

    console.log(`[reCAPTCHA] Iniciando protección (${this.v2Value ? 'v2' : 'v3'}) para acción: ${this.actionValue}`)

    submitBtn.classList.add("is-loading")
    submitBtn.disabled = true

    if (this.v2Value) {
      this.waitForRecaptchaV2(submitBtn)
    } else {
      this.executeRecaptchaV3(submitBtn)
    }
  }

  waitForRecaptchaV2(button) {
    console.log("[reCAPTCHA v2] Esperando que grecaptcha esté disponible...")
    const interval = setInterval(() => {
      if (window.grecaptcha) {
        clearInterval(interval)
        console.log("[reCAPTCHA v2] grecaptcha listo. Habilitando botón.")
        button.classList.remove("is-loading")
        button.disabled = false
      }
    }, 100)

    setTimeout(() => {
      if (button.disabled) {
        clearInterval(interval)
        console.warn("[reCAPTCHA v2] Tiempo de espera agotado. grecaptcha no cargó.")
      }
    }, 10000)
  }

  executeRecaptchaV3(button) {
    if (!window.grecaptcha) {
      console.warn("[reCAPTCHA v3] grecaptcha aún no está disponible.")
      return
    }

    console.log("[reCAPTCHA v3] Ejecutando reCAPTCHA...")
    grecaptcha.ready(() => {
      grecaptcha.execute(this.siteKeyValue, { action: this.actionValue }).then(token => {
        console.log("[reCAPTCHA v3] Token recibido. Insertando en formulario.")
        const input = document.createElement("input")
        input.type = "hidden"
        input.name = "g-recaptcha-response"
        input.value = token
        this.element.appendChild(input)

        console.log("[reCAPTCHA v3] grecaptcha listo. Habilitando botón.")
        button.classList.remove("is-loading")
        button.disabled = false
      }).catch(error => {
        console.error("[reCAPTCHA v3] Error al ejecutar reCAPTCHA:", error)
      })
    })
  }
}
