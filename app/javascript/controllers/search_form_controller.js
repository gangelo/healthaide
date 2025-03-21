import { Controller } from "@hotwired/stimulus"

/**
 * SearchFormController handles dynamic searching with Turbo
 * Uses direct frame updates for better performance
 */
export default class SearchFormController extends Controller {
  static targets = ["input", "results", "container"]
  static values = {
    url: String,
    debounce: { type: Number, default: 200 },
    frame: { type: String, default: "foods_list" }
  }

  connect() {
    // Set default URL if not provided
    if (!this.hasUrlValue) {
      this.urlValue = "/user_foods/select_multiple"
    }
    
    // Check if Turbo is loaded
    if (typeof Turbo === 'undefined') {
      console.error("Turbo is not loaded, but required for SearchFormController")
      return
    }
    
    // Initial search (useful when returning to page with existing search)
    if (this.inputTarget.value) {
      this.search()
    }
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      const searchTerm = this.inputTarget.value.trim()
      const url = new URL(this.urlValue, window.location.origin)
      
      // Only add search param if there's a value
      if (searchTerm) {
        url.searchParams.set("search", searchTerm)
      } else {
        url.searchParams.delete("search")
      }
      
      // Ensure we're targeting the specific frame
      url.searchParams.set("_frame", this.frameValue)
      
      // Find the frame to update
      const frame = document.querySelector(`turbo-frame#${this.frameValue}`)
      if (frame) {
        try {
          // Use native frame.src assignment which is more reliable
          frame.setAttribute("src", url.toString())
        } catch (e) {
          console.error("Error updating frame:", e)
          // Fallback to Turbo.visit
          Turbo.visit(url.toString(), { frame: this.frameValue })
        }
      } else {
        console.error(`Turbo Frame with ID "${this.frameValue}" not found`)
      }
    }, this.debounceValue)
  }

  // Clear the search input and refresh results
  clear() {
    this.inputTarget.value = ""
    this.search()
  }
}
