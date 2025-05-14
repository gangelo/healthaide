import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="pager-rows"
export default class extends Controller {
  static targets = ["select"];

  connect() {
    // Initialization if needed
  }

  changePageSize(event) {
    // Get the selected value from the dropdown
    const selectedValue = event.target.value;

    // Set the value in the hidden form field
    const hiddenField = document.querySelector("input[name='pager_rows']");
    if (hiddenField) {
      hiddenField.value = selectedValue;
    }

    // Submit the form
    const form = document.getElementById("pager_rows_form");
    if (form) {
      form.requestSubmit();
    }
  }
}
