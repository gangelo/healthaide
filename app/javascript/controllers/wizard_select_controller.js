import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "selectAllButton", "selectNoneButton", "counter"]
  static values = { 
    itemLabel: String
  }

  connect() {
    this.updateUI()
  }

  selectAll(event) {
    event.preventDefault()
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = true
    })
    this.updateUI()
  }

  selectNone(event) {
    event.preventDefault()
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = false
    })
    this.updateUI()
  }

  checkboxChanged() {
    this.updateUI()
  }

  updateUI() {
    const totalCheckboxes = this.checkboxTargets.length
    const checkedCount = this.checkboxTargets.filter(checkbox => checkbox.checked).length
    
    // Update counter
    if (this.hasCounterTarget) {
      const label = this.itemLabelValue || "item"
      this.counterTarget.textContent = `${checkedCount} ${label}${checkedCount !== 1 ? 's' : ''} selected`
    }
    
    // Update select all button
    if (this.hasSelectAllButtonTarget) {
      const allSelected = checkedCount === totalCheckboxes
      this.selectAllButtonTarget.disabled = allSelected || totalCheckboxes === 0
      this.selectAllButtonTarget.classList.toggle("opacity-50", allSelected || totalCheckboxes === 0)
      this.selectAllButtonTarget.classList.toggle("cursor-not-allowed", allSelected || totalCheckboxes === 0)
    }
    
    // Update select none button
    if (this.hasSelectNoneButtonTarget) {
      const noneSelected = checkedCount === 0
      this.selectNoneButtonTarget.disabled = noneSelected
      this.selectNoneButtonTarget.classList.toggle("opacity-50", noneSelected)
      this.selectNoneButtonTarget.classList.toggle("cursor-not-allowed", noneSelected)
    }
  }
}