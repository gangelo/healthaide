import { Controller } from "@hotwired/stimulus";

/**
 * Health Goal Selection Controller
 * Handles the shuttle-style health goal selection interface
 */
export default class extends Controller {
  static targets = [
    "searchInput",
    "availableList",
    "availableGoal",
    "selectedList",
    "selectedGoal",
    "emptySelectedMessage",
    "submitButton",
    "clearButton",
    "hiddenInputs",
    "newGoalForm",
    "newGoalInput",
    "form",
  ];

  connect() {
    this.selectedGoals = new Map(); // Map of goal_id -> {goal_id, name}
    this.updateButtons();
    this.debounceTimeout = null;
  }

  // Handle searching in the available goals list
  search() {
    clearTimeout(this.debounceTimeout);
    this.debounceTimeout = setTimeout(() => {
      const searchTerm = this.searchInputTarget.value.trim();

      if (searchTerm === "") {
        // Reset search - show all available goals
        this.availableGoalTargets.forEach((goal) => {
          goal.classList.remove("hidden");
        });
        this.newGoalFormTarget.classList.add("hidden");
        return;
      }

      // Client-side filtering for immediate feedback
      const searchTermLower = searchTerm.toLowerCase();
      let anyVisible = false;

      // Filter the available goals
      this.availableGoalTargets.forEach((goal) => {
        const goalName = goal.dataset.goalName.toLowerCase();

        if (goalName.includes(searchTermLower)) {
          goal.classList.remove("hidden");
          anyVisible = true;
        } else {
          goal.classList.add("hidden");
        }
      });

      // If no goals match, show the "Add new goal" form
      if (!anyVisible) {
        this.newGoalFormTarget.classList.remove("hidden");
        this.newGoalInputTarget.value = searchTerm;
      } else {
        this.newGoalFormTarget.classList.add("hidden");
      }
    }, 300);
  }

  // Close the new health goal form
  closeNewGoalForm() {
    // Clear the input and hide the form
    this.searchInputTarget.value = "";
    this.newGoalFormTarget.classList.add("hidden");

    // Clear the search text field
    this.searchInputTarget.value = "";

    // Show all available foods again
    this.availableGoalTargets.forEach((food) => {
      food.classList.remove("hidden");
    });
  }

  // Add a new goal from the search that wasn't found
  addNewGoal() {
    const goalName = this.newGoalInputTarget.value.trim();
    if (!goalName) return;

    // Create a unique ID for this new goal (negative to avoid conflicts with DB IDs)
    const tempId = `new-${Date.now()}`;

    // Add to selected goals
    this.selectedGoals.set(tempId, {
      goal_id: tempId,
      goal_name: goalName,
    });

    // Update UI
    this.renderSelectedGoals();
    this.updateButtons();

    // Clear search and hide new goal form
    this.searchInputTarget.value = "";
    this.newGoalFormTarget.classList.add("hidden");

    // Show all available goals again
    this.availableGoalTargets.forEach((goal) => {
      goal.classList.remove("hidden");
    });
  }

  // Select a goal from the available list
  selectGoal(event) {
    const goalElement = event.currentTarget;
    const goalId = goalElement.dataset.goalId;
    const goalName = goalElement.dataset.goalName;

    // Add to selected goals
    this.selectedGoals.set(goalId, {
      goal_id: goalId,
      goal_name: goalName,
    });

    // Hide this goal from the available list
    goalElement.classList.add("hidden");

    // Render selected goals
    this.renderSelectedGoals();
    this.updateButtons();
  }

  // Remove a goal from the selected list
  removeGoal(event) {
    const goalElement = event.currentTarget;
    const goalId = goalElement.dataset.goalId;

    // Remove from selected goals
    this.selectedGoals.delete(goalId);

    // If it's a real goal (not a new one), show it again in the available list
    if (!goalId.startsWith("new-")) {
      this.availableGoalTargets.forEach((goal) => {
        if (goal.dataset.goalId === goalId) {
          goal.classList.remove("hidden");
        }
      });
    }

    // Render selected goals
    this.renderSelectedGoals();
    this.updateButtons();
  }

  // Clear all selected goals
  clearSelections() {
    // Show all available goals again
    this.availableGoalTargets.forEach((goal) => {
      goal.classList.remove("hidden");
    });

    // Clear selected goals
    this.selectedGoals.clear();

    // Update UI
    this.renderSelectedGoals();
    this.updateButtons();
  }

  // Render the selected goals list
  renderSelectedGoals() {
    // Clear current selected goals
    const selectedGoalElements = this.selectedGoalTargets;
    selectedGoalElements.forEach((el) => el.remove());

    // Show/hide empty message
    if (this.selectedGoals.size === 0) {
      this.emptySelectedMessageTarget.classList.remove("hidden");
    } else {
      this.emptySelectedMessageTarget.classList.add("hidden");
    }

    // Re-render hidden inputs
    this.hiddenInputsTarget.innerHTML = "";

    // Add each selected goal
    this.selectedGoals.forEach((goal) => {
      // Add the selected goal element
      const goalHtml = this.renderSelectedGoalHtml(
        goal.goal_id,
        goal.goal_name
      );
      this.selectedListTarget.insertAdjacentHTML("beforeend", goalHtml);

      // Add hidden input for form submission
      if (goal.goal_id.startsWith("new-")) {
        // This is a new goal to create
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = "new_goal_names[]";
        input.value = goal.goal_name;
        this.hiddenInputsTarget.appendChild(input);
      } else {
        // This is an existing goal
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = "health_goal_ids[]";
        input.value = goal.goal_id;
        this.hiddenInputsTarget.appendChild(input);
      }
    });
  }

  // Generate HTML for a selected goal
  renderSelectedGoalHtml(goalId, goalName) {
    return `
      <div class="goal-item py-2 px-3 hover:bg-gray-50 rounded cursor-pointer mb-1 bg-gray-100"
           data-health-goal-selection-target="selectedGoal"
           data-goal-id="${goalId}"
           data-goal-name="${goalName}"
           data-action="click->health-goal-selection#removeGoal">
        <div class="flex items-center">
          <div class="flex-1">
            <div class="flex items-center">
              <div class="text-sm font-medium text-gray-900">
                ${goalName}
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
    const hasSelections = this.selectedGoals.size > 0;

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
}
