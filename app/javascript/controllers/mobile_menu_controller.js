import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon"];

  connect() {
    // Ensure menu is closed when controller connects
    this.closeMenu();
    
    // Handle window resize to close menu
    window.addEventListener("resize", this.closeMenu.bind(this));
    
    // Handle clicks outside the menu
    document.addEventListener("click", this.handleOutsideClick.bind(this));
    
    // Handle escape key press
    document.addEventListener("keydown", this.handleEscapeKey.bind(this));
  }

  disconnect() {
    // Clean up event listeners
    window.removeEventListener("resize", this.closeMenu.bind(this));
    document.removeEventListener("click", this.handleOutsideClick.bind(this));
    document.removeEventListener("keydown", this.handleEscapeKey.bind(this));
  }

  toggle() {
    const isOpen = !this.menuTarget.classList.contains("hidden");
    
    if (isOpen) {
      this.closeMenu();
    } else {
      this.openMenu();
    }
  }

  openMenu() {
    this.menuTarget.classList.remove("hidden");
    this.openIconTarget.classList.add("hidden");
    this.closeIconTarget.classList.remove("hidden");
  }

  closeMenu() {
    this.menuTarget.classList.add("hidden");
    this.openIconTarget.classList.remove("hidden");
    this.closeIconTarget.classList.add("hidden");
  }

  handleOutsideClick(event) {
    // Only process if menu is open and click is outside menu and button
    if (!this.menuTarget.classList.contains("hidden") && 
        !this.menuTarget.contains(event.target) && 
        !this.element.contains(event.target)) {
      this.closeMenu();
    }
  }

  handleEscapeKey(event) {
    if (event.key === "Escape" && !this.menuTarget.classList.contains("hidden")) {
      this.closeMenu();
    }
  }
}