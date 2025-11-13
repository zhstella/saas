import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.max = parseInt(this.element.dataset.tagPickerMaxValue || '5', 10)
  }

  toggle(event) {
    if (this.selectedCount() > this.max) {
      event.target.checked = false
      this.element.dispatchEvent(new CustomEvent('tag-picker:max-reached', { bubbles: true }))
      alert(`You can select up to ${this.max} tags.`)
    }
  }

  selectedCount() {
    return this.inputTargets.filter((input) => input.checked).length
  }
}
