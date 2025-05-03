import { Controller } from "@hotwired/stimulus";

/**
 * SearchFormController handles dynamic searching with Turbo
 * Uses direct frame updates for better performance
 */
export default class SearchFormController extends Controller {
  static targets = ["input", "results", "container"];
  static values = {
    debounce: { type: Number, default: 200 },
    frame: { type: String, default: "search_results" },
    url: String,
  };

  connect() {
    // Check if Turbo is loaded
    if (typeof Turbo === "undefined") {
      console.error(
        "Turbo is not loaded, but required for SearchFormController"
      );
      return;
    }

    // Set default URL if needed - can be overridden in subclasses
    if (!this.hasUrlValue) {
      this.urlValue = window.location.pathname;
    }

    // Initial search (useful when returning to page with existing search)
    if (this.inputTarget.value) {
      this.search();
    }
  }

  search() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      const searchTerm = this.inputTarget.value.trim();
      const url = new URL(this.urlValue, window.location.origin);

      // Only add search param if there's a value
      if (searchTerm) {
        url.searchParams.set("search", searchTerm);
      } else {
        url.searchParams.delete("search");
      }

      // Make sure we have a frameValue and it's not empty
      const frameId = this.frameValue || this.getDefaultFrameId();

      // Use a consistent parameter name for frame targeting
      url.searchParams.set("frame_id", frameId);

      // Find the frame to update
      const frame = document.querySelector(`turbo-frame#${frameId}`);
      if (frame) {
        try {
          // Use native frame.src assignment which is more reliable
          frame.setAttribute("src", url.toString());
        } catch (e) {
          console.error("Error updating frame:", e);
          // Fallback to Turbo.visit
          Turbo.visit(url.toString(), { frame: this.frameValue });
        }
      } else {
        console.error(`Turbo Frame with ID "${frameId}" not found`);
      }
    }, this.debounceValue);
  }

  // Clear the search input and refresh results
  clear() {
    this.inputTarget.value = "";
    this.search();
  }

  // Get the default frame ID if not specified in values
  getDefaultFrameId() {
    return "search_results";
  }
}
