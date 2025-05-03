import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step"]

  connect() {
    // Initialize wizard steps
    this.showCurrentStep()
  }

  showCurrentStep() {
    // Get the current step from the form
    const currentStep = parseInt(this.element.querySelector('input[name="current_step"]').value)
    
    // Show only the current step
    this.stepTargets.forEach(step => {
      const stepNumber = parseInt(step.dataset.step)
      if (stepNumber === currentStep) {
        step.classList.remove('hidden')
      } else {
        step.classList.add('hidden')
      }
    })
  }
}