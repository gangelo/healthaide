import { Controller } from "@hotwired/stimulus"

/**
 * Modal controller for managing modal dialogs and food selection
 * Works with Turbo Frame based modals for better integration
 */
export default class ModalController extends Controller {
  static targets = ["submitButton", "selectionCount", "selectAllButton", "selectNoneButton"]
  static values = {
    selectedFoods: { type: Array, default: [] }
  }

  connect() {
    // Add event listener for ESC key
    document.addEventListener("keydown", this.handleKeyDown.bind(this))
    document.body.classList.add("overflow-hidden")
    
    // Listen for turbo:frame-load events to restore selection state
    document.addEventListener("turbo:frame-load", this.restoreSelectionState.bind(this))

    // Initialize the selection count and button state
    this.updateSelectionState()
  }

  disconnect() {
    // Remove event listeners when controller is disconnected
    document.removeEventListener("keydown", this.handleKeyDown.bind(this))
    document.removeEventListener("turbo:frame-load", this.restoreSelectionState.bind(this))
    document.body.classList.remove("overflow-hidden")
  }

  close() {
    // Close the modal using Turbo
    const frameId = this.element.closest("turbo-frame")?.id
    if (frameId) {
      Turbo.visit(window.location.href, { frame: frameId })
    }
  }

  handleKeyDown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  // Close modal if clicking outside of modal content
  clickOutside(event) {
    // Get the modal dialog content - assuming it's the first .bg-white element
    const modalContent = this.element.querySelector(".bg-white")
    // If click is outside the modal content, close it
    if (modalContent && !modalContent.contains(event.target)) {
      this.close()
    }
  }

  // Track checkbox changes to maintain selection state
  checkboxChanged(event) {
    const checkbox = event.target
    const foodId = checkbox.value
    
    if (checkbox.checked) {
      // Add to selected foods if not already there
      if (!this.selectedFoodsValue.includes(foodId)) {
        this.selectedFoodsValue = [...this.selectedFoodsValue, foodId]
      }
    } else {
      // Remove from selected foods
      this.selectedFoodsValue = this.selectedFoodsValue.filter(id => id !== foodId)
    }
    
    this.updateSelectionState()
  }
  
  // Restore selection state when the foods list is updated
  restoreSelectionState(event) {
    if (event.target.id === "foods_list") {
      const checkboxes = event.target.querySelectorAll('input[type="checkbox"]')
      
      checkboxes.forEach(checkbox => {
        // Check if this food ID is in our selected foods array
        checkbox.checked = this.selectedFoodsValue.includes(checkbox.value)
        
        // Ensure the checkboxes have the event listener
        checkbox.removeEventListener("change", this.checkboxChanged.bind(this))
        checkbox.addEventListener("change", this.checkboxChanged.bind(this))
      })
      
      this.updateSelectionState()
    }
  }

  // Select all visible foods
  selectAll() {
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"]:not(:checked)')
    checkboxes.forEach(checkbox => {
      checkbox.checked = true
      
      // Add to selected foods
      const foodId = checkbox.value
      if (!this.selectedFoodsValue.includes(foodId)) {
        this.selectedFoodsValue = [...this.selectedFoodsValue, foodId]
      }
    })
    
    this.updateSelectionState()
  }
  
  // Deselect all foods
  selectNone() {
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"]:checked')
    checkboxes.forEach(checkbox => checkbox.checked = false)
    
    // Clear selected foods array
    this.selectedFoodsValue = []
    
    this.updateSelectionState()
  }

  // Update the selection count and button state
  updateSelectionState() {
    if (!this.hasSubmitButtonTarget || !this.hasSelectionCountTarget) {
      return
    }

    const count = this.selectedFoodsValue.length
    const submitButton = this.submitButtonTarget
    const selectionCount = this.selectionCountTarget

    // Update selection count text
    selectionCount.textContent = `${count} food${count === 1 ? '' : 's'} selected`

    // Update submit button state
    submitButton.disabled = count === 0
    submitButton.classList.toggle('opacity-50', count === 0)
    submitButton.classList.toggle('cursor-not-allowed', count === 0)
    submitButton.classList.toggle('bg-blue-300', count === 0)
    submitButton.classList.toggle('bg-blue-600', count > 0)
    
    // Update select all/none buttons if we have them
    if (this.hasSelectAllButtonTarget) {
      const allCheckboxes = this.element.querySelectorAll('input[type="checkbox"]')
      const checkedCheckboxes = this.element.querySelectorAll('input[type="checkbox"]:checked')
      
      // Disable "Select All" when all visible checkboxes are checked
      this.selectAllButtonTarget.disabled = allCheckboxes.length === checkedCheckboxes.length
      this.selectAllButtonTarget.classList.toggle('opacity-50', allCheckboxes.length === checkedCheckboxes.length)
      this.selectAllButtonTarget.classList.toggle('cursor-not-allowed', allCheckboxes.length === checkedCheckboxes.length)
    }
    
    if (this.hasSelectNoneButtonTarget) {
      // Disable "Select None" when nothing is checked
      this.selectNoneButtonTarget.disabled = count === 0
      this.selectNoneButtonTarget.classList.toggle('opacity-50', count === 0)
      this.selectNoneButtonTarget.classList.toggle('cursor-not-allowed', count === 0)
    }
  }
}
