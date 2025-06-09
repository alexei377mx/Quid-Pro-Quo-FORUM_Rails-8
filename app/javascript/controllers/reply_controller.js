import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "textarea"];

  connect() {
    console.log("reply controller connected")
  }

  open(event) {
    event.preventDefault();
    const parentId = event.params.parentId;
    const mention = event.params.mention;

    document.querySelectorAll("[id^='reply-form-']").forEach(form => {
      form.style.display = 'none';
    });

    const form = document.getElementById(`reply-form-${parentId}`);
    if (!form) return;
    form.style.display = 'block';

    const textarea = form.querySelector('textarea');
    if (!textarea) return;

    if (textarea.value.trim() === '') {
      textarea.value = `${mention} `;
    }

    textarea.focus();
    textarea.setSelectionRange(textarea.value.length, textarea.value.length);

    setTimeout(() => {
      textarea.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }, 100);
  }
}
