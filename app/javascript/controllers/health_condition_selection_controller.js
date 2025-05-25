import { Controller } from "@hotwired/stimulus";

/**
 * Health Condition Selection Controller
 * Handles the shuttle-style health condition selection interface
 */
export default class extends Controller {
  static targets = [
    "searchInput",
    "availableList",
    "availableCondition",
    "selectedList",
    "selectedCondition",
    "emptySelectedMessage",
    "submitButton",
    "clearButton",
    "hiddenInputs",
    "newConditionForm",
    "newConditionInput",
    "form",
  ];

  connect() {
    this.selectedConditions = new Map(); // Map of condition_id -> {condition_id, name}
    this.updateButtons();
    this.debounceTimeout = null;
  }

  // Handle searching in the available conditions list
  search() {
    clearTimeout(this.debounceTimeout);
    this.debounceTimeout = setTimeout(() => {
      const searchTerm = this.searchInputTarget.value.trim();

      if (searchTerm === "") {
        // Reset search - show all available conditions
        this.availableConditionTargets.forEach((condition) => {
          const conditionName = condition.dataset.conditionName;
          if (!this.alreadySelectedCondition(conditionName)) {
            condition.classList.remove("hidden");
          }
        });
        this.newConditionFormTarget.classList.add("hidden");
        return;
      }

      // Client-side filtering for immediate feedback
      const searchTermLower = searchTerm.toLowerCase();
      let anyVisible = false;

      // Filter the available conditions
      this.availableConditionTargets.forEach((condition) => {
        const conditionName = condition.dataset.conditionName.toLowerCase();

        if (
          conditionName.includes(searchTermLower) &&
          !this.alreadySelectedCondition(conditionName)
        ) {
          condition.classList.remove("hidden");
          anyVisible = true;
        } else {
          condition.classList.add("hidden");
        }
      });

      // If no conditions match, show the "Add new condition" form as long as it
      // is not already selected.
      if (!anyVisible && !this.alreadySelectedCondition(searchTerm)) {
        this.newConditionFormTarget.classList.remove("hidden");
        this.newConditionInputTarget.value = searchTerm;
      } else {
        this.newConditionFormTarget.classList.add("hidden");
      }
    }, 300);
  }

  // Close the new health condition form
  closeNewConditionForm() {
    // Clear the input and hide the form
    this.newConditionInputTarget.value = "";
    this.newConditionFormTarget.classList.add("hidden");

    // Clear the search text field
    this.searchInputTarget.value = "";

    // Show all available foods again
    this.availableConditionTargets.forEach((food) => {
      food.classList.remove("hidden");
    });
  }

  // Add a new condition from the search that wasn't found
  addNewCondition() {
    const conditionName = this.newConditionInputTarget.value.trim();
    if (!conditionName) return;

    // Create a unique ID for this new condition (negative to avoid conflicts with DB IDs)
    const tempId = `new-${Date.now()}`;

    // Add to selected conditions
    this.selectedConditions.set(tempId, {
      condition_id: tempId,
      condition_name: conditionName,
    });

    // Update UI
    this.renderSelectedConditions();
    this.updateButtons();

    // Clear search and hide new condition form
    this.searchInputTarget.value = "";
    this.newConditionFormTarget.classList.add("hidden");

    // Show all available conditions again
    this.availableConditionTargets.forEach((condition) => {
      condition.classList.remove("hidden");
    });
  }

  // Select a condition from the available list
  selectCondition(event) {
    const conditionElement = event.currentTarget;
    const conditionId = conditionElement.dataset.conditionId;
    const conditionName = conditionElement.dataset.conditionName;

    // Add to selected conditions
    this.selectedConditions.set(conditionId, {
      condition_id: conditionId,
      condition_name: conditionName,
    });

    // Hide this condition from the available list
    conditionElement.classList.add("hidden");

    // Render selected conditions
    this.renderSelectedConditions();
    this.updateButtons();
  }

  // Remove a condition from the selected list
  removeCondition(event) {
    const conditionElement = event.currentTarget;
    const conditionId = conditionElement.dataset.conditionId;

    // Remove from selected conditions
    this.selectedConditions.delete(conditionId);

    // If it's a real condition (not a new one), show it again in the available list
    if (!conditionId.startsWith("new-")) {
      this.availableConditionTargets.forEach((condition) => {
        if (condition.dataset.conditionId === conditionId) {
          condition.classList.remove("hidden");
        }
      });
    }

    // Render selected conditions
    this.renderSelectedConditions();
    this.updateButtons();
  }

  // Clear all selected conditions
  clearSelections() {
    // Show all available conditions again
    this.availableConditionTargets.forEach((condition) => {
      condition.classList.remove("hidden");
    });

    // Clear selected conditions
    this.selectedConditions.clear();

    // Update UI
    this.renderSelectedConditions();
    this.updateButtons();
  }

  // Render the selected conditions list
  renderSelectedConditions() {
    // Clear current selected conditions
    const selectedConditionElements = this.selectedConditionTargets;
    selectedConditionElements.forEach((el) => el.remove());

    // Show/hide empty message
    if (this.selectedConditions.size === 0) {
      this.emptySelectedMessageTarget.classList.remove("hidden");
    } else {
      this.emptySelectedMessageTarget.classList.add("hidden");
    }

    // Re-render hidden inputs
    this.hiddenInputsTarget.innerHTML = "";

    // Add each selected condition
    this.selectedConditions.forEach((condition) => {
      // Add the selected condition element
      const conditionHtml = this.renderSelectedConditionHtml(
        condition.condition_id,
        condition.condition_name
      );
      this.selectedListTarget.insertAdjacentHTML("beforeend", conditionHtml);

      // Add hidden input for form submission
      if (condition.condition_id.startsWith("new-")) {
        // This is a new condition to create
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = "new_condition_names[]";
        input.value = condition.condition_name;
        this.hiddenInputsTarget.appendChild(input);
      } else {
        // This is an existing condition
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = "health_condition_ids[]";
        input.value = condition.condition_id;
        this.hiddenInputsTarget.appendChild(input);
      }
    });
  }

  // Generate HTML for a selected condition
  renderSelectedConditionHtml(conditionId, conditionName) {
    return `
      <div class="condition-item py-2 px-3 hover:bg-gray-50 rounded cursor-pointer mb-1 bg-gray-100"
           data-health-condition-selection-target="selectedCondition"
           data-condition-id="${conditionId}"
           data-condition-name="${conditionName}"
           data-action="click->health-condition-selection#removeCondition">
        <div class="flex items-center">
          <div class="flex-1">
            <div class="flex items-center">
              <div class="text-sm font-medium text-gray-900">
                ${conditionName}
              </div>
            </div>
          </div>
          <div class="ml-2 text-red-600">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15 12H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
        </div>
      </div>
    `;
  }

  // Update the submit and clear buttons state
  updateButtons() {
    const hasSelections = this.selectedConditions.size > 0;

    this.submitButtonTarget.disabled = !hasSelections;
    this.clearButtonTarget.disabled = !hasSelections;

    if (hasSelections) {
      this.submitButtonTarget.classList.remove(
        "opacity-50",
        "cursor-not-allowed"
      );
      this.clearButtonTarget.classList.remove(
        "opacity-50",
        "cursor-not-allowed"
      );
    } else {
      this.submitButtonTarget.classList.add("opacity-50", "cursor-not-allowed");
      this.clearButtonTarget.classList.add("opacity-50", "cursor-not-allowed");
    }
  }

  alreadySelectedCondition(conditionName) {
    // Check if the health condition is already selected
    return Array.from(this.selectedConditions.values()).some(
      (condition) =>
        condition.condition_name.toLowerCase() === conditionName.toLowerCase()
    );
  }
}
