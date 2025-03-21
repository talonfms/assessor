import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button"]

  select(event) {
    // Remove active class from all buttons
    this.buttonTargets.forEach(button => 
      button.classList.remove("bg-gray-300")
    )
    
    // Add active class to clicked button
    event.currentTarget.classList.add("bg-gray-300")
    
    // Update hidden input value
    this.inputTarget.value = event.currentTarget.dataset.value
  }
}