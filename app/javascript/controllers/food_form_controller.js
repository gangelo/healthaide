import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "dropdown", "foodId", "input"]

  connect() {
  }

  handleInput(event) {
    // Clear the search input and food ID when typing in the new food input
    this.searchInputTarget.value = ''
    this.foodIdTarget.value = ''
  }

  searchAndFilter(event) {
    // Clear the new food input when typing in the search
    this.inputTarget.value = ''

    const searchTerm = event.target.value.toLowerCase()
    const options = this.dropdownTarget.querySelectorAll('[role="option"]')
    let hasVisibleOptions = false

    options.forEach(option => {
      const foodName = option.getAttribute('data-food-name')
      if (foodName.includes(searchTerm)) {
        option.classList.remove('hidden')
        hasVisibleOptions = true
      } else {
        option.classList.add('hidden')
      }
    })

    // Show/hide the dropdown based on whether there are matches
    if (hasVisibleOptions) {
      this.showOptions()
    } else {
      this.hideOptions()
    }

    // Update ARIA attributes
    this.searchInputTarget.setAttribute('aria-expanded', hasVisibleOptions.toString())
  }

  showOptions() {
    this.dropdownTarget.classList.remove('hidden')
  }

  hideOptions() {
    this.dropdownTarget.classList.add('hidden')
  }

  handleBlur(event) {
    // Small delay to allow click events to fire on options
    setTimeout(() => {
      this.hideOptions()
    }, 200)
  }

  selectOption(event) {
    const option = event.currentTarget
    const foodId = option.getAttribute('data-value')
    const foodName = option.textContent.trim()

    this.searchInputTarget.value = foodName
    this.foodIdTarget.value = foodId
    this.inputTarget.value = '' // Clear the new food input
    this.hideOptions()
  }
}
