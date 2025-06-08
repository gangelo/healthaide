import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "clearButton",
    "datalist",
    "frequency",
    "lastValidMedication",
    "searchContainer",
    "searchInput",
    "submitButton",
  ];
  static debounceTimeout = 300;

  connect() {
    this.debounceTimer = null;
    this.validMedications = new Set();
    this.justSelected = false;

    this.searchInputTarget.addEventListener("input", () => {
      if (this.doSearch()) this.searchMedication();
    });
  }

  searchMedication() {
    // Re-enable validation on next input after selection
    if (this.justSelected) {
      this.justSelected = false;
    }

    clearTimeout(this.debounceTimer);

    const query = this.searchInputTarget.value.trim();

    // Show/hide clear button based on input content
    this.updateClearButton();

    // Only validate if we haven't just made a selection
    if (!this.justSelected) {
      this.updateMedication();
    }

    if (query.length < 2) {
      this.clearResults();
      return;
    }

    this.debounceTimer = setTimeout(() => {
      this.performSearch(query);
    }, this.constructor.debounceTimeout);
  }

  clear() {
    this.searchInputTarget.value = "";
    this.clearResults();
    this.updateClearButton();
    this.updateMedication();
    this.searchInputTarget.focus();
    this.justSelected = false; // Reset selection flag
  }

  updateClearButton() {
    const hasContent = this.searchInputTarget.value.trim().length > 0;
    if (hasContent) {
      this.clearButtonTarget.classList.remove("hidden");
    } else {
      this.clearButtonTarget.classList.add("hidden");
    }
  }

  async performSearch(query) {
    try {
      const response = await fetch(
        `/user_medications/search?search=${encodeURIComponent(query)}`,
        {
          headers: {
            Accept: "application/json",
            "X-Requested-With": "XMLHttpRequest",
          },
        }
      );

      if (response.ok) {
        const data = await response.json();
        this.updateResults(data.medications);
      } else {
        console.error("Search failed:", response.statusText);
        this.clearResults();
      }
    } catch (error) {
      console.error("Search error:", error);
      this.clearResults();
    }
  }

  updateResults(medications) {
    // Clear existing options
    this.datalistTarget.innerHTML = "";
    this.validMedications.clear();

    if (medications && medications.length > 0) {
      medications.forEach((medication) => {
        const option = document.createElement("option");
        option.value = medication;
        this.datalistTarget.appendChild(option);
        this.validMedications.add(medication);
      });
    }

    // Only validate if we haven't just made a selection
    if (!this.justSelected) {
      this.updateMedication();
    }
  }

  clearResults() {
    this.datalistTarget.innerHTML = "";
    this.validMedications.clear();

    // Only validate if we haven't just made a selection
    if (!this.justSelected) {
      this.updateMedication();
    }
  }

  isMedicationValid(medication) {
    medication = medication.trim();
    return (
      this.validMedications.has(medication) ||
      this.isLastValidMedicationSelected(medication)
    );
  }

  isLastValidMedicationSelected(medication) {
    return this.lastValidMedicationTarget.dataset.value === medication;
  }

  isFrequencyValid() {
    return this.frequencyTarget.value.trim() !== "";
  }

  enableSubmitButton(enable) {
    this.submitButtonTarget.disabled = !enable;
  }

  frequencyChanged() {
    this.updateMedication();
  }

  doSearch() {
    return this.searchInputTarget.value.trim().length > 1;
  }

  updateMedication() {
    const medication = this.searchInputTarget.value.trim();
    const isValid = this.isMedicationValid(medication);

    this.enableSubmitButton(isValid && this.isFrequencyValid());

    if (medication === "") {
      this.searchContainerTarget.classList.remove(
        "border-red-500",
        "border-green-500"
      );
      this.searchContainerTarget.classList.add("border-gray-300");
      this.lastValidMedicationTarget.dataset.value = undefined;
    } else if (isValid) {
      this.lastValidMedicationTarget.dataset.value = medication;
      this.searchContainerTarget.classList.remove(
        "border-red-500",
        "border-gray-300"
      );
      this.searchContainerTarget.classList.add("border-green-500");
    } else {
      this.searchContainerTarget.classList.remove(
        "border-green-500",
        "border-gray-300"
      );
      this.searchContainerTarget.classList.add("border-red-500");
    }
  }
}
