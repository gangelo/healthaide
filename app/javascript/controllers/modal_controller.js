import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "foodList", "selectionCount"]

  connect() {
    // Initialize the selection count
    this.updateCount()
  }

  open() {
    this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }

  selectAll() {
    this.checkboxes.forEach(checkbox => checkbox.checked = true)
    this.updateCount()
  }

  selectNone() {
    this.checkboxes.forEach(checkbox => checkbox.checked = false)
    this.updateCount()
  }

  updateCount() {
    const count = this.checkboxes.filter(checkbox => checkbox.checked).length
    this.selectionCountTarget.textContent = `${count} food${count === 1 ? '' : 's'} selected`
  }

  filterFoods(event) {
    const searchTerm = event.target.value.toLowerCase()
    const foodItems = this.foodListTarget.querySelectorAll("[data-food-name]")

    foodItems.forEach(item => {
      const foodName = item.dataset.foodName
      if (foodName.includes(searchTerm)) {
        item.classList.remove("hidden")
      } else {
        item.classList.add("hidden")
      }
    })
  }

  get checkboxes() {
    return Array.from(this.element.querySelectorAll('input[type="checkbox"]'))
  }
}
