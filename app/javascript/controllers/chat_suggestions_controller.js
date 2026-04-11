import { Controller } from "@hotwired/stimulus"

// Fills the chat composer textarea with a suggestion prompt on click
export default class extends Controller {
  static targets = ["input"]

  fill(event) {
    const button = event.currentTarget
    const prompt = button.dataset.prompt

    if (!this.hasInputTarget || !prompt) return

    this.inputTarget.value = prompt
    this.inputTarget.focus()

    // Move cursor to end
    const len = prompt.length
    this.inputTarget.setSelectionRange(len, len)

    // Auto-resize textarea to fit content
    this.inputTarget.style.height = "auto"
    this.inputTarget.style.height = `${this.inputTarget.scrollHeight}px`
  }
}
