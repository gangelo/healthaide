import { Controller } from "@hotwired/stimulus";

/**
 * Food Selection Controller
 * Handles the shuttle-style food selection interface
 */
export default class extends Controller {
  static targets = [
    "searchInput",
    "availableList",
    "availableFood",
    "selectedList",
    "selectedFood",
    "emptySelectedMessage",
    "submitButton",
    "clearButton",
    "hiddenInputs",
    "newFoodForm",
    "newFoodInput",
    "form",
  ];

  connect() {
    this.selectedFoods = new Map(); // Map of food_id -> {food_id, name, display_name}
    this.updateButtons();
    this.debounceTimeout = null;
  }

  // Handle searching in the available foods list
  search() {
    clearTimeout(this.debounceTimeout);
    this.debounceTimeout = setTimeout(() => {
      const searchTerm = this.searchInputTarget.value.trim();

      if (searchTerm === "") {
        // Reset search - show all available foods
        this.availableFoodTargets.forEach((food) => {
          food.classList.remove("hidden");
        });
        this.newFoodFormTarget.classList.add("hidden");
        return;
      }

      // Client-side filtering for immediate feedback
      const searchTermLower = searchTerm.toLowerCase();
      let anyVisible = false;

      // Filter the available foods
      this.availableFoodTargets.forEach((food) => {
        const foodName = food.dataset.foodName.toLowerCase();
        if (foodName.includes(searchTermLower)) {
          food.classList.remove("hidden");
          anyVisible = true;
        } else {
          food.classList.add("hidden");
        }
      });

      // If no foods match, show the "Add new food" form
      if (!anyVisible) {
        this.newFoodFormTarget.classList.remove("hidden");
        this.newFoodInputTarget.value = searchTerm;
      } else {
        this.newFoodFormTarget.classList.add("hidden");
      }
    }, 300);
  }

  // Close the new food form
  closeNewFoodForm() {
    // Clear the input and hide the form
    this.newFoodInputTarget.value = "";
    this.newFoodFormTarget.classList.add("hidden");

    // Clear the search text field
    this.searchInputTarget.value = "";

    // Show all available foods again
    this.availableFoodTargets.forEach((food) => {
      food.classList.remove("hidden");
    });
  }

  // Add a new food from the search that wasn't found
  addNewFood() {
    const foodName = this.newFoodInputTarget.value.trim();
    if (!foodName) return;

    // Create a unique ID for this new food (negative to avoid conflicts with DB IDs)
    const tempId = `new-${Date.now()}`;

    // Add to selected foods
    this.selectedFoods.set(tempId, {
      food_id: tempId,
      food_name: foodName,
      display_name: foodName,
    });

    // Update UI
    this.renderSelectedFoods();
    this.updateButtons();

    // Clear search and hide new food form
    this.searchInputTarget.value = "";
    this.newFoodFormTarget.classList.add("hidden");

    // Show all available foods again
    this.availableFoodTargets.forEach((food) => {
      food.classList.remove("hidden");
    });
  }

  // Select a food from the available list
  selectFood(event) {
    const foodElement = event.currentTarget;
    const foodId = foodElement.dataset.foodId;
    const foodName = foodElement.dataset.foodName;

    // Add to selected foods
    this.selectedFoods.set(foodId, {
      food_id: foodId,
      food_name: foodName,
    });

    // Hide this food from the available list
    foodElement.classList.add("hidden");

    // Render selected foods
    this.renderSelectedFoods();
    this.updateButtons();
  }

  // Remove a food from the selected list
  removeFood(event) {
    const foodElement = event.currentTarget;
    const foodId = foodElement.dataset.foodId;

    // Remove from selected foods
    this.selectedFoods.delete(foodId);

    // If it's a real food (not a new one), show it again in the available list
    if (!foodId.startsWith("new-")) {
      this.availableFoodTargets.forEach((food) => {
        if (food.dataset.foodId === foodId) {
          food.classList.remove("hidden");
        }
      });
    }

    // Render selected foods
    this.renderSelectedFoods();
    this.updateButtons();
  }

  // Clear all selected foods
  clearSelections() {
    // Show all available foods again
    this.availableFoodTargets.forEach((food) => {
      food.classList.remove("hidden");
    });

    // Clear selected foods
    this.selectedFoods.clear();

    // Update UI
    this.renderSelectedFoods();
    this.updateButtons();
  }

  // Render the selected foods list
  renderSelectedFoods() {
    // Clear current selected foods
    const selectedFoodElements = this.selectedFoodTargets;
    selectedFoodElements.forEach((el) => el.remove());

    // Show/hide empty message
    if (this.selectedFoods.size === 0) {
      this.emptySelectedMessageTarget.classList.remove("hidden");
    } else {
      this.emptySelectedMessageTarget.classList.add("hidden");
    }

    // Re-render hidden inputs
    this.hiddenInputsTarget.innerHTML = "";

    // Add each selected food
    this.selectedFoods.forEach((food) => {
      // Add the selected food element
      const foodHtml = this.renderSelectedFoodHtml(
        food.food_id,
        food.food_name,
        food.display_name
      );
      this.selectedListTarget.insertAdjacentHTML("beforeend", foodHtml);

      // Add hidden input for form submission
      if (food.food_id.startsWith("new-")) {
        // This is a new food to create using nested attributes
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = "new_food_names[]";
        input.value = food.food_name;
        this.hiddenInputsTarget.appendChild(input);
      } else {
        // This is an existing food
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = "food_ids[]";
        input.value = food.food_id;
        this.hiddenInputsTarget.appendChild(input);
      }
    });
  }

  // Generate HTML for a selected food
  renderSelectedFoodHtml(foodId, foodName) {
    return `
      <div class="food-item py-2 px-3 hover:bg-gray-50 rounded cursor-pointer mb-1 bg-gray-100"
           data-food-selection-target="selectedFood"
           data-food-id="${foodId}"
           data-food-name="${foodName}"
           data-action="click->food-selection#removeFood">
        <div class="flex items-center">
          <div class="flex-1">
            <div class="text-sm font-medium text-gray-900">${foodName}</div>
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
    const hasSelections = this.selectedFoods.size > 0;

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
