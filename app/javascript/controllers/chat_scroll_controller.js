import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
    document.addEventListener("turbo:before-stream-render", this.scrollToBottom.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.scrollToBottom.bind(this))
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }
}
