import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["source"];

  connect() {
    // Controller connected
  }

  copy() {
    const content = this.sourceTarget.textContent.trim();

    navigator.clipboard.writeText(content).then(
      () => {
        // Success feedback
        this.showFeedback("Copied to clipboard!");
      },
      () => {
        // Error feedback
        this.showFeedback("Failed to copy", true);
      }
    );
  }

  showFeedback(message, isError = false) {
    // Show temporary feedback
    const button = this.element.querySelector("button");
    const originalText = button.innerHTML;

    button.classList.add(isError ? "bg-red-600" : "bg-green-600");
    button.classList.add("text-white");
    button.innerHTML = message;

    setTimeout(() => {
      button.classList.remove(isError ? "bg-red-600" : "bg-green-600");
      button.classList.remove("text-white");
      button.innerHTML = originalText;
    }, 2000);
  }
}
