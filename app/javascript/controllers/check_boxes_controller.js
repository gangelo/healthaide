import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="check-boxes"
export default class extends Controller {
  static targets = ["selectAll", "selectNone", "submitButton", "userSelect"];

  connect() {
    this.updateButtonState();
  }

  // Update our content frame
  updateContent() {
    // Get all selected checkboxes values
    const selectedOptions = this.checkboxes
      .filter((checkbox) => checkbox.checked)
      .map((checkbox) => checkbox.value);

    // Get the selected user
    const userId = this.userSelectTarget.value;

    if (userId && selectedOptions.length > 0) {
      // Build the URL with query parameters
      const url =
        `/exports/preview?user_id=${userId}&` +
        selectedOptions.map((opt) => `export_options[]=${opt}`).join("&");

      // Find the Turbo Frame and update its source
      const frame = document.getElementById("main_content");
      if (frame) {
        frame.src = url;
      }
    }
  }

  // Handle a checkbox being toggled
  checkboxChanged() {
    this.updateButtonState();
    this.updateContent();
  }

  // When user select changes
  userChanged() {
    this.updateButtonState();
    this.updateContent();
  }

  // Select all checkboxes
  selectAll(event) {
    event.preventDefault();
    this.checkboxes.forEach((checkbox) => {
      checkbox.checked = true;
    });
    this.updateButtonState();
    this.updateContent();
  }

  // Deselect all checkboxes
  selectNone(event) {
    event.preventDefault();
    this.checkboxes.forEach((checkbox) => {
      checkbox.checked = false;
    });
    this.updateButtonState();
    this.updateContent();
  }

  // Update the state of all buttons based on selection
  updateButtonState() {
    const count = this.selectedCount;
    const userSelected = this.userSelectTarget.value !== "";

    // Update the submit button - disabled if no checkboxes selected OR no user selected
    const submitDisabled = count === 0 || !userSelected;
    this.submitButtonTarget.disabled = submitDisabled;
    this.submitButtonTarget.classList.toggle("opacity-50", submitDisabled);
    this.submitButtonTarget.classList.toggle(
      "cursor-not-allowed",
      submitDisabled
    );
    this.submitButtonTarget.classList.toggle(
      "hover:bg-blue-500",
      !submitDisabled
    );

    // Update the select none button
    if (this.hasSelectNoneTarget) {
      const selectNoneEl = this.selectNoneTarget;
      selectNoneEl.classList.toggle("opacity-50", count === 0);
      selectNoneEl.classList.toggle("cursor-not-allowed", count === 0);
    }

    // Update the select all button
    if (this.hasSelectAllTarget) {
      const selectAllEl = this.selectAllTarget;
      const allSelected =
        count === this.checkboxes.length && this.checkboxes.length > 0;
      selectAllEl.classList.toggle("opacity-50", allSelected);
      selectAllEl.classList.toggle("cursor-not-allowed", allSelected);
    }
  }

  // Get all checkboxes in the form
  get checkboxes() {
    return Array.from(this.element.querySelectorAll('input[type="checkbox"]'));
  }

  // Get the count of selected checkboxes
  get selectedCount() {
    return this.checkboxes.filter((checkbox) => checkbox.checked).length;
  }
}
