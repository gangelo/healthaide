import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "itemList", "submitButton"];

  connect() {
    this.modal = document.getElementById("selectHealthGoalModal");
  }

  showModal() {
    this.modalTarget.classList.remove("hidden");
  }

  close() {
    this.modalTarget.classList.add("hidden");
  }

  filterItems(event) {
    const searchTerm = event.target.value.toLowerCase();
    const items = this.itemListTarget.querySelectorAll("[data-item-name]");

    items.forEach((item) => {
      const name = item.dataset.itemName;
      item.classList.toggle("hidden", !name.includes(searchTerm));
    });
  }

  enableSubmit(event) {
    this.submitButtonTarget.disabled = false;
    this.submitButtonTarget.classList.remove(
      "opacity-50",
      "cursor-not-allowed"
    );
  }

  submit(event) {
    const selectedGoal = this.itemListTarget.querySelector(
      'input[name="health_goal_id"]:checked'
    );
    if (selectedGoal) {
      const form = document.createElement("form");
      form.method = "POST";
      form.action = "/user_health_goals";

      const csrfToken = document.querySelector(
        "meta[name='csrf-token']"
      ).content;
      const csrfInput = document.createElement("input");
      csrfInput.type = "hidden";
      csrfInput.name = "authenticity_token";
      csrfInput.value = csrfToken;

      const goalInput = document.createElement("input");
      goalInput.type = "hidden";
      goalInput.name = "user_health_goal[health_goal_id]";
      goalInput.value = selectedGoal.value;

      const importanceInput = document.createElement("input");
      importanceInput.type = "hidden";
      importanceInput.name = "user_health_goal[order_of_importance]";
      importanceInput.value = "5"; // Default value, can be adjusted later

      form.appendChild(csrfInput);
      form.appendChild(goalInput);
      form.appendChild(importanceInput);
      document.body.appendChild(form);
      form.submit();
    }
  }
}
