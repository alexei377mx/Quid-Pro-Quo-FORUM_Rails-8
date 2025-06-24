import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    copiedMessage: String,
    errorMessage: String,
    noticeTitle: String,
    errorTitle: String,
    infoTitle: String
  }

   connect() {
    console.log("clipboard radio controller connected")
   }

  copy() {
    navigator.clipboard.writeText(this.urlValue)
      .then(() => {
        this.showNotification(this.copiedMessageValue, "notice")
      })
      .catch(() => {
        this.showNotification(this.errorMessageValue, "error")
      })
  }

  showNotification(message, type = "info") {
    const container = document.getElementById("dynamic-flash-container")
    if (!container) return

    const classes = {
      notice: {
        title: this.noticeTitleValue,
        icon: "fa-circle-check",
        color: "is-success"
      },
      error: {
        title: this.errorTitleValue,
        icon: "fa-circle-exclamation",
        color: "is-danger"
      },
      info: {
        title: this.infoTitleValue,
        icon: "fa-circle-info",
        color: "is-info"
      }
    }

    const { title, icon, color } = classes[type] || classes["info"]

    const notif = document.createElement("div")
    notif.className = `notification ${color} animate__animated animate__slideInRight`
    notif.setAttribute("data-controller", "notification")

    notif.innerHTML = `
      <button class="delete" data-action="click->notification#close"></button>
      <span class="icon-text">
        <span class="icon">
          <i class="fas ${icon}"></i>
        </span>
        <span><strong>${title}</strong></span>
      </span>
      <br>
      ${message}
    `

    container.appendChild(notif)

    setTimeout(() => {
      notif.classList.remove("animate__slideInRight")
      notif.classList.add("animate__slideOutRight")
      notif.addEventListener("animationend", () => notif.remove())
    }, 3000)
  }
}
