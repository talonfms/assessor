// app/javascript/controllers/blocks_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "list", "form", "template" ]

  connect() {
    this.sortable = new Sortable(this.listTarget, {
      animation: 150,
      onEnd: this.updateOrder.bind(this)
    })
  }

  async addBlock(event) {
    event.preventDefault()
    const response = await fetch(this.formTarget.action, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
      },
      body: new FormData(this.formTarget)
    })
    const data = await response.json()
    if (data.success) {
      this.listTarget.insertAdjacentHTML('beforeend', data.html)
      this.formTarget.reset()
    } else {
      // Handle errors
      console.error(data.errors)
    }
  }

  async editBlock(event) {
    const blockId = event.params.id
    const response = await fetch(`/workflows/${this.workflowId}/blocks/${blockId}/edit`, {
      headers: { 'Accept': 'text/html' }
    })
    const html = await response.text()
    this.formTarget.innerHTML = html
  }

  async updateBlock(event) {
    event.preventDefault()
    const response = await fetch(this.formTarget.action, {
      method: 'PATCH',
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
      },
      body: new FormData(this.formTarget)
    })
    const data = await response.json()
    if (data.success) {
      const blockElement = this.listTarget.querySelector(`[data-block-id="${event.params.id}"]`)
      blockElement.outerHTML = data.html
      this.formTarget.innerHTML = this.templateTarget.innerHTML
    } else {
      // Handle errors
      console.error(data.errors)
    }
  }

  async deleteBlock(event) {
    if (confirm('Are you sure you want to delete this block?')) {
      const blockId = event.params.id
      const response = await fetch(`/workflows/${this.workflowId}/blocks/${blockId}`, {
        method: 'DELETE',
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
        }
      })
      const data = await response.json()
      if (data.success) {
        event.target.closest('[data-block-id]').remove()
      } else {
        // Handle errors
        console.error(data.errors)
      }
    }
  }

  async updateOrder() {
    const blockIds = Array.from(this.listTarget.children).map(el => el.dataset.blockId)
    await fetch(`/workflows/${this.workflowId}/blocks/reorder`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ block_ids: blockIds })
    })
  }

  get workflowId() {
    return this.element.dataset.workflowId
  }
}