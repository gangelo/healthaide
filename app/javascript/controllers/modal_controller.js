import { Controller } from "@hotwired/stimulus";

/**
 * Modal controller for managing modal dialogs and food selection
 * Works with Turbo Frame based modals for better integration
 */
export default class ModalController extends Controller {
  static targets = [
    "submitButton",
    "selectionCount",
    "selectAllButton",
    "selectNoneButton",
  ];
  static values = {
    selectedItems: { type: Array, default: [] },
    itemType: { type: String, default: "food" }, // Can be "food" or "health_condition"
  };

  connect() {
    // Add event listener for ESC key
    document.addEventListener("keydown", this.handleKeyDown.bind(this));
    document.body.classList.add("overflow-hidden");

    // Listen for turbo:frame-load events to restore selection state
    document.addEventListener(
      "turbo:frame-load",
      this.restoreSelectionState.bind(this)
    );

    // Initialize the selection count and button state
    this.updateSelectionState();
  }

  disconnect() {
    // Remove event listeners when controller is disconnected
    document.removeEventListener("keydown", this.handleKeyDown.bind(this));
    document.removeEventListener(
      "turbo:frame-load",
      this.restoreSelectionState.bind(this)
    );
    document.body.classList.remove("overflow-hidden");
  }

  close() {
    // Close the modal using Turbo
    const frameId = this.element.closest("turbo-frame")?.id;
    if (frameId) {
      Turbo.visit(window.location.href, { frame: frameId });
    }
  }

  handleKeyDown(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }

  // Close modal if clicking outside of modal content
  clickOutside(event) {
    // Get the modal dialog content - assuming it's the first .bg-white element
    const modalContent = this.element.querySelector(".bg-white");
    // If click is outside the modal content, close it
    if (modalContent && !modalContent.contains(event.target)) {
      this.close();
    }
  }

  // Track checkbox changes to maintain selection state
  checkboxChanged(event) {
    const checkbox = event.target;
    const itemId = checkbox.value;

    if (checkbox.checked) {
      // Add to selected items if not already there
      if (!this.selectedItemsValue.includes(itemId)) {
        this.selectedItemsValue = [...this.selectedItemsValue, itemId];
      }
    } else {
      // Remove from selected items
      this.selectedItemsValue = this.selectedItemsValue.filter(
        (id) => id !== itemId
      );
    }

    this.updateSelectionState();
  }

  // Restore selection state when the list is updated
  restoreSelectionState(event) {
    // Check if we're dealing with foods or health conditions frame
    const validFrameIds = ["foods_list", "conditions_list"];
    if (validFrameIds.includes(event.target.id)) {
      const checkboxes = event.target.querySelectorAll(
        'input[type="checkbox"]'
      );

      checkboxes.forEach((checkbox) => {
        // Check if this item ID is in our selected items array
        checkbox.checked = this.selectedItemsValue.includes(checkbox.value);

        // Ensure the checkboxes have the event listener
        checkbox.removeEventListener("change", this.checkboxChanged.bind(this));
        checkbox.addEventListener("change", this.checkboxChanged.bind(this));
      });

      this.updateSelectionState();
    }
  }

  // Select all visible items
  selectAll() {
    const checkboxes = this.element.querySelectorAll(
      'input[type="checkbox"]:not(:checked)'
    );
    checkboxes.forEach((checkbox) => {
      checkbox.checked = true;

      // Add to selected items
      const itemId = checkbox.value;
      if (!this.selectedItemsValue.includes(itemId)) {
        this.selectedItemsValue = [...this.selectedItemsValue, itemId];
      }
    });

    this.updateSelectionState();
  }

  // Deselect all items
  selectNone() {
    const checkboxes = this.element.querySelectorAll(
      'input[type="checkbox"]:checked'
    );
    checkboxes.forEach((checkbox) => (checkbox.checked = false));

    // Clear selected items array
    this.selectedItemsValue = [];

    this.updateSelectionState();
  }

  // Update the selection count and button state
  updateSelectionState() {
    if (!this.hasSubmitButtonTarget || !this.hasSelectionCountTarget) {
      return;
    }

    const count = this.selectedItemsValue.length;
    const submitButton = this.submitButtonTarget;
    const selectionCount = this.selectionCountTarget;

    // Determine the item type label (default to "item")
    let itemTypeLabel = "item";

    // Check the page path to set the item type
    if (window.location.pathname.includes("user_foods")) {
      itemTypeLabel = "food";
    } else if (window.location.pathname.includes("user_health_conditions")) {
      itemTypeLabel = "health condition";
    } else if (this.hasItemTypeValue) {
      itemTypeLabel = this.itemTypeValue;
    }

    // Update selection count text
    selectionCount.textContent = `${count} ${itemTypeLabel}${
      count === 1 ? "" : "s"
    } selected`;

    // Update submit button state
    submitButton.disabled = count === 0;
    submitButton.classList.toggle("opacity-50", count === 0);
    submitButton.classList.toggle("cursor-not-allowed", count === 0);
    submitButton.classList.toggle("bg-blue-300", count === 0);
    submitButton.classList.toggle("bg-blue-600", count > 0);

    // Update select all/none buttons if we have them
    if (this.hasSelectAllButtonTarget) {
      const allCheckboxes = this.element.querySelectorAll(
        'input[type="checkbox"]'
      );
      const checkedCheckboxes = this.element.querySelectorAll(
        'input[type="checkbox"]:checked'
      );

      // Disable "Select All" when all visible checkboxes are checked
      this.selectAllButtonTarget.disabled =
        allCheckboxes.length === checkedCheckboxes.length;
      this.selectAllButtonTarget.classList.toggle(
        "opacity-50",
        allCheckboxes.length === checkedCheckboxes.length
      );
      this.selectAllButtonTarget.classList.toggle(
        "cursor-not-allowed",
        allCheckboxes.length === checkedCheckboxes.length
      );
    }

    if (this.hasSelectNoneButtonTarget) {
      // Disable "Select None" when nothing is checked
      this.selectNoneButtonTarget.disabled = count === 0;
      this.selectNoneButtonTarget.classList.toggle("opacity-50", count === 0);
      this.selectNoneButtonTarget.classList.toggle(
        "cursor-not-allowed",
        count === 0
      );
    }
  }
}
