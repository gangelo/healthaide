import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "itemList", "selectionCount", "submitButton"]

  connect() {
    // Only initialize if we have the necessary targets
    if (this.hasItemListTarget && this.hasSelectionCountTarget) {
      this.updateCount()
    }
    // Ensure modal is hidden initially
    if (this.hasModalTarget) {
      this.close()
    }
  }

  open() {
    this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }

  updateCount() {
    const checkedCount = this.itemListTarget.querySelectorAll('input[type="checkbox"]:checked').length
    this.selectionCountTarget.textContent = `${checkedCount} conditions selected`

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

  filterItems(event) {
    const searchTerm = event.target.value.toLowerCase()
    const items = this.itemListTarget.querySelectorAll('[data-item-name]')

    items.forEach(item => {
      const name = item.dataset.itemName
      item.classList.toggle('hidden', !name.includes(searchTerm))
    })
  }

  selectAll() {
    const checkboxes = this.itemListTarget.querySelectorAll('input[type="checkbox"]')
    checkboxes.forEach(checkbox => {
      checkbox.checked = true
    })
    this.updateCount()
  }

  selectNone() {
    const checkboxes = this.itemListTarget.querySelectorAll('input[type="checkbox"]')
    checkboxes.forEach(checkbox => {
      checkbox.checked = false
    })
    this.updateCount()
  }

  addSelectedItems(event) {
    const checkedBoxes = this.itemListTarget.querySelectorAll('input[type="checkbox"]:checked')
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = '/user_health_conditions/add_multiple'

    // Add CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    const csrfInput = document.createElement('input')
    csrfInput.type = 'hidden'
    csrfInput.name = 'authenticity_token'
    csrfInput.value = csrfToken
    form.appendChild(csrfInput)

    // Add selected condition IDs
    checkedBoxes.forEach(checkbox => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'health_condition_ids[]'
      input.value = checkbox.value
      form.appendChild(input)
    })

    document.body.appendChild(form)
    form.submit()
  }
}
