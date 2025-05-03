import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["handle", "input"]
  static values = { 
    checked: Boolean,
    url: String
  }

  connect() {
    this.updateUI()
  }

  toggle() {
    this.checkedValue = !this.checkedValue
    this.updateUI()
    
    // If this is an AJAX toggle with a URL, submit the change
    if (this.hasUrlValue) {
      this.submitChange()
    }
  }

  updateUI() {
    // Update the aria-checked attribute
    this.element.setAttribute("aria-checked", this.checkedValue)
    
    // Update the button background color
    if (this.checkedValue) {
      this.element.classList.add("bg-indigo-600")
      this.element.classList.remove("bg-gray-200")
    } else {
      this.element.classList.remove("bg-indigo-600")
      this.element.classList.add("bg-gray-200")
    }
    
    // Update the handle position
    if (this.hasHandleTarget) {
      if (this.checkedValue) {
        this.handleTarget.classList.add("translate-x-5")
        this.handleTarget.classList.remove("translate-x-0")
      } else {
        this.handleTarget.classList.remove("translate-x-5")
        this.handleTarget.classList.add("translate-x-0")
      }
    }
    
    // Update the hidden input value if it exists
    if (this.hasInputTarget) {
      this.inputTarget.value = this.checkedValue ? this.inputTarget.dataset.onValue || "1" : this.inputTarget.dataset.offValue || "0"
    }
  }

  submitChange() {
    // Get CSRF token from meta tag
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content")
    
    // Determine the HTTP method (default to PATCH)
    const method = this.element.dataset.turboMethod || "patch"
    
    // Submit the request using fetch
    fetch(this.urlValue, {
      method: method.toUpperCase(),
      headers: {
        "X-CSRF-Token": csrfToken,
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html"
      },
      credentials: "same-origin"
    })
    .catch(error => {
      console.error("Error toggling status:", error)
      // Revert the UI changes on error
      this.checkedValue = !this.checkedValue
      this.updateUI()
    })
  }
}