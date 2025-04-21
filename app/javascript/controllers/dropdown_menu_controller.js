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
    
    const isHidden = this.menuTarget.classList.contains("hidden");
    
    if (isHidden) {
      // Show menu with animation
      this.menuTarget.classList.remove("hidden");
      
      // Use setTimeout to ensure the transition works
      setTimeout(() => {
        this.menuTarget.classList.remove("opacity-0", "scale-95");
        this.menuTarget.classList.add("opacity-100", "scale-100");
      }, 10);
    } else {
      // Hide menu with animation
      this.menuTarget.classList.add("opacity-0", "scale-95");
      this.menuTarget.classList.remove("opacity-100", "scale-100");
      
      // Use setTimeout to wait for animation to complete before hiding
      setTimeout(() => {
        this.menuTarget.classList.add("hidden");
      }, 100);
    }

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
      // Hide with animation
      this.menuTarget.classList.add("opacity-0", "scale-95");
      this.menuTarget.classList.remove("opacity-100", "scale-100");
      
      // Use setTimeout to wait for animation to complete before hiding
      setTimeout(() => {
        this.menuTarget.classList.add("hidden");
      }, 100);
      
      this.iconTarget.classList.remove("rotate-180");
      this.element
        .querySelector("button")
        .setAttribute("aria-expanded", "false");
    }
  }
}
