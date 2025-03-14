import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "foodList", "selectionCount", "submitButton"]

  connect() {
    // Initialize the selection count and button state
    this.updateCount()
  }

  open() {
    this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }

  selectAll() {
    this.foodListTarget.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
      checkbox.checked = true
    })
    this.updateCount()
  }

  selectNone() {
    this.foodListTarget.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
      checkbox.checked = false
    })
    this.updateCount()
  }

  updateCount() {
    const checkedCount = this.foodListTarget.querySelectorAll('input[type="checkbox"]:checked').length
    this.selectionCountTarget.textContent = `${checkedCount} foods selected`

    // Update submit button state
    if (checkedCount > 0) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove('opacity-50', 'cursor-not-allowed')
      this.submitButtonTarget.classList.add('hover:bg-blue-500')
    } else {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add('opacity-50', 'cursor-not-allowed')
      this.submitButtonTarget.classList.remove('hover:bg-blue-500')
    }
  }

  filterFoods(event) {
    const searchTerm = event.target.value.toLowerCase()
    const foodItems = this.foodListTarget.querySelectorAll('[data-food-name]')

    foodItems.forEach(item => {
      const foodName = item.getAttribute('data-food-name')
      if (foodName.includes(searchTerm)) {
        item.classList.remove('hidden')
      } else {
        item.classList.add('hidden')
      }
    })
  }

  addSelectedFoods(event) {
    const checkedBoxes = this.foodListTarget.querySelectorAll('input[type="checkbox"]:checked')
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = '/user_foods/add_multiple'

    // Add CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    const csrfInput = document.createElement('input')
    csrfInput.type = 'hidden'
    csrfInput.name = 'authenticity_token'
    csrfInput.value = csrfToken
    form.appendChild(csrfInput)

    // Add selected food IDs
    checkedBoxes.forEach(checkbox => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'food_ids[]'
      input.value = checkbox.value
      form.appendChild(input)
    })

    document.body.appendChild(form)
    form.submit()
  }
}
