import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]

  connect() {
    // Controller connected
  }

  copy() {
    const content = this.sourceTarget.textContent.trim()
    
    navigator.clipboard.writeText(content).then(
      () => {
        // Success feedback
        this.showFeedback("Copied to clipboard!")
      },
      () => {
        // Error feedback
        this.showFeedback("Failed to copy", true)
      }
    )
  }

  showFeedback(message, isError = false) {
    // Show temporary feedback
    const button = this.element.querySelector("button")
    const originalText = button.innerHTML
    
    button.classList.add(isError ? "bg-red-50" : "bg-green-50")
    button.innerHTML = message
    
    setTimeout(() => {
      button.classList.remove(isError ? "bg-red-50" : "bg-green-50")
      button.innerHTML = originalText
    }, 2000)
  }
}