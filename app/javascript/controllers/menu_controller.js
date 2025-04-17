// app/javascript/controllers/menu_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["openIcon", "closeIcon"];

  connect() {
    // Get a reference to the menu element (now moved inside the controller element)
    this.menuElement = document.getElementById("mobile-menu-dropdown");

    // This closes the menu, if it is open, when the window is resized
    addEventListener("resize", (event) => {
      const button = this.element.querySelector("button");
      const isExpanded = button.getAttribute("aria-expanded") === "true";
      if (isExpanded) {
        this.toggle();
      }
    });
  }

  toggle() {
    // Toggle the icons
    this.openIconTarget.classList.toggle("hidden");
    this.closeIconTarget.classList.toggle("hidden");

    // Toggle the menu visibility
    this.menuElement.classList.toggle("hidden");

    // Toggle the aria-expanded attribute for accessibility
    const button = this.element.querySelector("button");
    const isExpanded = button.getAttribute("aria-expanded") === "true";
    button.setAttribute("aria-expanded", !isExpanded);
  }
}
