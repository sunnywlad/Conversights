import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handler = () => this.element.remove()
    document.addEventListener("turbo:before-stream-render", this.handler)
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.handler)
  }
}
