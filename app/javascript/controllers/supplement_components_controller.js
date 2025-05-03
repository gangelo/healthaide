import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "container"]
  
  connect() {
    this.index = this.containerTarget.dataset.nextIndex || 0
  }
  
  addComponent(event) {
    event.preventDefault()
    
    // Clone the template
    const content = this.templateTarget.content.cloneNode(true)
    
    // Replace NEW_RECORD with the current index
    const fields = content.querySelectorAll("input")
    fields.forEach(field => {
      field.name = field.name.replace('NEW_RECORD', this.index)
    })
    
    // Add the new component to the container
    this.containerTarget.appendChild(content)
    
    // Increment the index
    this.index++
  }
  
  removeComponent(event) {
    const button = event.currentTarget
    const row = button.closest('.grid')
    
    // If there's a destroy input field, mark for destruction
    const destroyInput = row.querySelector('.destroy-field')
    if (destroyInput) {
      destroyInput.value = "1"
      row.style.display = "none"
    } else {
      // Otherwise, just remove the row (for new unsaved components)
      row.remove()
    }
  }
}