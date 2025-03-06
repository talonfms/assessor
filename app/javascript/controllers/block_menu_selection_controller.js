import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "content"]
  
  static values = {
    activeClass: { type: String, default: "bg-gray-200" },
    defaultBlock: { type: String, default: "" }
  }

  connect() {
    // Show default content if specified
    console.log("HELLO")
    if (this.defaultBlockValue) {
      this.showContent(this.defaultBlockValue)
    } else {
      // Hide all content initially
      this.contentTargets.forEach(content => {
        content.style.display = "none"
      })
      
      // Show "No block selected" message
      const noBlockSelected = this.contentTargets.find(content => 
        content.querySelector("h4")?.textContent.trim() === "No block selected"
      )
      if (noBlockSelected) {
        noBlockSelected.style.display = "block"
      }
    }
  }

  select(event) {
    // Get block type from button's data attribute
    const blockType = event.currentTarget.dataset.blockType
    
    // Update buttons active state
    this.buttonTargets.forEach(button => {
      if (button === event.currentTarget) {
        button.classList.add(this.activeClassValue)
      } else {
        button.classList.remove(this.activeClassValue)
      }
    })

    this.showContent(blockType)
  }

  showContent(blockType) {
    // Hide all content sections
    this.contentTargets.forEach(content => {
      content.style.display = "none"
    })

    // Show selected content
    const selectedContent = this.contentTargets.find(content => 
      content.getAttribute("data-block-type") === blockType
    )
    if (selectedContent) {
      selectedContent.style.display = "block"
    }
  }
}