import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["icon"];

  connect() {
    console.log("theme controller connected")
    const savedTheme = localStorage.getItem("theme") || "light";
    document.documentElement.setAttribute("data-theme", savedTheme);
    this.updateIcon(savedTheme);
  }

  toggle() {
    const html = document.documentElement;
    const current = html.getAttribute("data-theme");
    const next = current === "dark" ? "light" : "dark";
    html.setAttribute("data-theme", next);
    localStorage.setItem("theme", next);
    this.updateIcon(next);
  }

  updateIcon(theme) {
    if (!this.hasIconTarget) return;
    this.iconTarget.className = theme === "dark" ? "fas fa-sun" : "fas fa-moon";
  }
}
