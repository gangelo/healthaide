import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "input"]

  connect() {
    // Set initial state
    this.resetForm()
  }

  resetForm() {
    // Reset select to prompt option
    this.selectTarget.value = ""
    // Clear input
    this.inputTarget.value = ""
  }

  handleInput(event) {
    const input = event.target
    if (input.value.length > 0) {
      // If user types anything, reset select to prompt
      this.selectTarget.value = ""
    }
  }

  handleSelect(event) {
    const select = event.target
    if (select.value !== "") {
      // If user selects anything other than prompt, clear input
      this.inputTarget.value = ""
    }
  }
}
