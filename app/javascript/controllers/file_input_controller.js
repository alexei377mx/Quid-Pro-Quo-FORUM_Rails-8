import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "fileName"]

  connect() {
    console.log("file_input_controller connected")
    this.updateFileName()
  }

  updateFileName() {
    const files = this.inputTarget.files
    this.fileNameTarget.textContent = files.length > 0
      ? files[0].name
      : "No hay archivo seleccionado"
  }
}
