import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu", "icon"];

  connect() {
    // Close the dropdown when clicking outside
    document.addEventListener("click", this.closeOnClickOutside.bind(this));
  }

  disconnect() {
    // Clean up event listener when controller disconnects
    document.removeEventListener("click", this.closeOnClickOutside.bind(this));
  }

  toggle(event) {
    event.stopPropagation();
    this.menuTarget.classList.toggle("hidden");

    // Rotate the dropdown icon
    this.iconTarget.classList.toggle("rotate-180");

    // Toggle the aria-expanded attribute for accessibility
    const button = event.currentTarget;
    const isExpanded = button.getAttribute("aria-expanded") === "true";
    button.setAttribute("aria-expanded", !isExpanded);
  }

  closeOnClickOutside(event) {
    // Only process when the menu is open
    if (this.menuTarget.classList.contains("hidden")) {
      return;
    }

    // Close if the click is outside the controller element
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden");
      this.iconTarget.classList.remove("rotate-180");
      this.element
        .querySelector("button")
        .setAttribute("aria-expanded", "false");
    }
  }
}
