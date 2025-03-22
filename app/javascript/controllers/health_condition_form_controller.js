import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "dropdown", "conditionId", "input"]

  connect() {
    this.hideDropdown()
  }

  searchAndFilter(event) {
    const searchTerm = event.target.value.toLowerCase()
    const options = this.dropdown.querySelectorAll("[data-condition-name]")

    options.forEach(option => {
      const name = option.dataset.conditionName
      option.classList.toggle("hidden", !name.includes(searchTerm))
    })

    this.showDropdown()
  }

  showOptions() {
    this.showDropdown()
  }

  handleBlur(event) {
    // Give time for the click event to fire on the option before hiding
    setTimeout(() => {
      this.hideDropdown()
    }, 200)
  }

  selectOption(event) {
    const option = event.currentTarget
    this.conditionIdTarget.value = option.dataset.value
    this.searchInputTarget.value = option.textContent.trim()
    this.inputTarget.value = "" // Clear the new condition name field
    this.hideDropdown()
  }

  handleInput(event) {
    if (event.target.value.length > 0) {
      this.conditionIdTarget.value = "" // Clear the selected condition
      this.searchInputTarget.value = "" // Clear the search input
    }
  }

  showDropdown() {
    this.dropdownTarget.classList.remove("hidden")
  }

  hideDropdown() {
    this.dropdownTarget.classList.add("hidden")
  }

  get dropdown() {
    return this.dropdownTarget
  }
}
