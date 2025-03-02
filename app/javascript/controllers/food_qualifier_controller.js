import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["qualifierName", "errorMessage"]

  connect() {
    console.log("Food qualifier controller connected")
  }

  validateForm(event) {
    const qualifierName = this.qualifierNameTarget.value.trim()

    if (!qualifierName) {
      event.preventDefault()
      this.showError("Please enter a qualifier name")
      return false
    }
  }

  showError(message) {
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.textContent = message
      this.errorMessageTarget.classList.remove("hidden")
    }
  }
}
