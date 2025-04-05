import { Controller } from "@hotwired/stimulus";

/**
 * SelectController handles multi-select interfaces for items.
 * It manages select all/none functionality, tracking selected count,
 * enabling/disabling submit buttons based on selection state.
 */
export default class SelectController extends Controller {
  static targets = [
    "submitButton",
    "selectAllButton",
    "selectNoneButton",
    "selectionCount",
  ];
  static values = {
    itemType: String,
    itemTypeLabel: String,
  };

  connect() {
    this.updateButtonState();
  }

  // Handle a checkbox being toggled
  checkboxChanged(event) {
    this.updateButtonState();
  }

  // Select all checkboxes
  selectAll(event) {
    event.preventDefault();
    this.checkboxes.forEach((checkbox) => {
      checkbox.checked = true;
    });
    this.updateButtonState();
  }

  // Deselect all checkboxes
  selectNone(event) {
    event.preventDefault();
    this.checkboxes.forEach((checkbox) => {
      checkbox.checked = false;
    });
    this.updateButtonState();
  }

  // Close modal when clicking outside
  clickOutside(event) {
    // Only handle clicks on the modal backdrop
    if (
      event.target.classList.contains("fixed") &&
      event.target.classList.contains("inset-0")
    ) {
      const closeButton = this.element.querySelector(
        'a[data-turbo-frame="modal"]'
      );
      if (closeButton) closeButton.click();
    }
  }

  // Update the state of all buttons based on selection
  updateButtonState() {
    const count = this.selectedCount;

    // Update selection counter
    const label = this.itemTypeLabelValue || this.itemTypeValue || "items";

    console.log(
      `select_controller.js: itemTypeLabelValue: ${this.itemTypeLabelValue}`
    );
    console.log(`select_controller.js: itemTypeValue: ${this.itemTypeValue}`);

    this.selectionCountTarget.textContent = `${count} ${label}${count !== 1 ? "s" : ""} selected`;

    // Update the submit button
    this.submitButtonTarget.disabled = count === 0;
    this.submitButtonTarget.classList.toggle("opacity-50", count === 0);
    this.submitButtonTarget.classList.toggle("cursor-not-allowed", count === 0);
    this.submitButtonTarget.classList.toggle("hover:bg-blue-700", count > 0);

    // Update the select none button
    this.selectNoneButtonTarget.disabled = count === 0;
    this.selectNoneButtonTarget.classList.toggle("opacity-50", count === 0);
    this.selectNoneButtonTarget.classList.toggle(
      "cursor-not-allowed",
      count === 0
    );

    // Update the select all button
    const allSelected = count === this.checkboxes.length;
    this.selectAllButtonTarget.disabled =
      allSelected && this.checkboxes.length > 0;
    this.selectAllButtonTarget.classList.toggle(
      "opacity-50",
      allSelected && this.checkboxes.length > 0
    );
    this.selectAllButtonTarget.classList.toggle(
      "cursor-not-allowed",
      allSelected && this.checkboxes.length > 0
    );
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
