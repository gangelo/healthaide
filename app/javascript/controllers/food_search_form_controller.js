import SearchFormController from "controllers/search_form_controller";

/**
 * FoodSearchFormController specializes the SearchFormController for food searches
 */
export default class FoodSearchFormController extends SearchFormController {
  static targets = [...SearchFormController.targets, "container"];

  static values = {
    ...SearchFormController.values,
    listFrameId: { type: String, default: "foods_list" },
    resourceType: { type: String, default: "food" },
    searchPath: { type: String, default: "/user_foods/select_multiple" },
  };

  connect() {
    super.connect();
    this.searchTimeout = null;
  }

  getDefaultFrameId() {
    return this.listFrameIdValue;
  }

  // Override the search method to use the updated values pattern
  search() {
    clearTimeout(this.searchTimeout);

    this.searchTimeout = setTimeout(() => {
      const searchTerm = this.inputTarget.value.trim();
      const url = new URL(this.searchPathValue, window.location.origin);

      // Only add search param if there's a value
      if (searchTerm) {
        url.searchParams.set("search", searchTerm);
      } else {
        url.searchParams.delete("search");
      }

      // Use a consistent parameter name for frame targeting
      url.searchParams.set("frame_id", this.listFrameIdValue);

      // Find the frame to update
      const frame = document.querySelector(
        `turbo-frame#${this.listFrameIdValue}`
      );

      if (frame) {
        try {
          // Use native frame.src assignment which is more reliable
          frame.setAttribute("src", url.toString());
        } catch (e) {
          console.error("Error updating frame:", e);
          // Fallback to Turbo.visit
          Turbo.visit(url.toString(), { frame: this.listFrameIdValue });
        }
      } else {
        console.error(
          `Turbo Frame with ID "${this.listFrameIdValue}" not found`
        );
      }
    }, this.debounceValue || 200);
  }
}
