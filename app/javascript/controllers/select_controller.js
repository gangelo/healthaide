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
    "hiddenContainer"
  ];
  static values = {
    itemType: String,
    itemTypeLabel: String,
  };

  connect() {
    // Initialize selected items storage
    this.selectedItemsMap = new Map(); // Map for quick lookups by ID
    this.updateButtonState();
    
    // Wait a small amount of time to ensure all checkboxes are rendered
    setTimeout(() => {
      this.applyCheckboxStates();
    }, 50);
  }

  // Handle a checkbox being toggled
  checkboxChanged(event) {
    const checkbox = event.target;
    const itemId = checkbox.value;
    
    // When a checkbox is checked
    if (checkbox.checked) {
      this.addSelectedItem(itemId);
    } else {
      this.removeSelectedItem(itemId);
    }
    
    this.updateButtonState();
  }

  // Add a selected item to our storage
  addSelectedItem(itemId) {
    if (!this.selectedItemsMap.has(itemId)) {
      this.selectedItemsMap.set(itemId, true);
      this.updateHiddenFields();
    }
  }

  // Remove a selected item from our storage
  removeSelectedItem(itemId) {
    if (this.selectedItemsMap.has(itemId)) {
      this.selectedItemsMap.delete(itemId);
      this.updateHiddenFields();
    }
  }

  // Update hidden fields to preserve selection state across Turbo refreshes
  updateHiddenFields() {
    // Clear existing hidden fields
    const container = this.hasHiddenContainerTarget ? 
                       this.hiddenContainerTarget : 
                       this.createHiddenContainer();
    
    container.innerHTML = '';
    
    // Create hidden fields for all selected items
    this.selectedItemsMap.forEach((_, itemId) => {
      const hiddenField = document.createElement('input');
      hiddenField.type = 'hidden';
      hiddenField.name = `_selected_items[]`;
      hiddenField.value = itemId;
      hiddenField.dataset.selectTarget = "hiddenField";
      container.appendChild(hiddenField);
    });
  }
  
  // Create a container for our hidden fields if it doesn't exist
  createHiddenContainer() {
    const container = document.createElement('div');
    container.dataset.selectTarget = "hiddenContainer";
    container.style.display = 'none';
    this.element.querySelector('form').appendChild(container);
    return container;
  }

  // Apply checkbox states from our storage
  applyCheckboxStates() {
    // First check if we have hidden fields and restore from them
    if (this.hasHiddenContainerTarget) {
      const hiddenFields = this.hiddenContainerTarget.querySelectorAll('input[type="hidden"]');
      
      hiddenFields.forEach(field => {
        this.selectedItemsMap.set(field.value, true);
      });
    }
    
    // Now apply these states to visible checkboxes
    this.checkboxes.forEach(checkbox => {
      if (this.selectedItemsMap.has(checkbox.value)) {
        checkbox.checked = true;
      }
    });
    
    this.updateButtonState();
  }

  // Select all checkboxes
  selectAll(event) {
    event.preventDefault();
    this.checkboxes.forEach((checkbox) => {
      checkbox.checked = true;
      this.addSelectedItem(checkbox.value);
    });
    this.updateButtonState();
  }

  // Deselect all checkboxes
  selectNone(event) {
    event.preventDefault();
    this.checkboxes.forEach((checkbox) => {
      checkbox.checked = false;
      this.removeSelectedItem(checkbox.value);
    });
    
    // Clear all selected items
    this.selectedItemsMap.clear();
    this.updateHiddenFields();
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
        'a[data-turbo-frame="_top"]'
      );
      if (closeButton) closeButton.click();
    }
  }

  // Update the state of all buttons based on selection
  updateButtonState() {
    const count = this.selectedCount;

    // Update selection counter
    const label = this.itemTypeLabelValue || this.itemTypeValue || "items";

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
    const allSelected = count === this.checkboxes.length && this.checkboxes.length > 0;
    this.selectAllButtonTarget.disabled = allSelected;
    this.selectAllButtonTarget.classList.toggle("opacity-50", allSelected);
    this.selectAllButtonTarget.classList.toggle("cursor-not-allowed", allSelected);
  }

  // Get all checkboxes in the form
  get checkboxes() {
    return Array.from(this.element.querySelectorAll('input[type="checkbox"]'));
  }

  // Get the count of selected checkboxes
  get selectedCount() {
    return this.selectedItemsMap.size;
  }
}
