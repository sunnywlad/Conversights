import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
    this.onSubmitEnd = this.scheduleScrollOnNextStream.bind(this)
    document.addEventListener("turbo:submit-end", this.onSubmitEnd)
  }

  disconnect() {
    document.removeEventListener("turbo:submit-end", this.onSubmitEnd)
  }

  scheduleScrollOnNextStream() {
    const userHandler = () => {
      document.removeEventListener("turbo:before-stream-render", userHandler)
      this.scheduleScrollToBotStart()
      requestAnimationFrame(() => {
        const userMessages = this.element.querySelectorAll(".chat-message--user")
        const lastUserMessage = userMessages[userMessages.length - 1]
        if (lastUserMessage) {
          const containerTop = this.element.getBoundingClientRect().top
          const messageTop = lastUserMessage.getBoundingClientRect().top
          this.element.scrollTop += messageTop - containerTop
        }
      })
    }
    document.addEventListener("turbo:before-stream-render", userHandler)
  }

  scheduleScrollToBotStart() {
    const chunks = 10
    let count = 0
    const observer = new MutationObserver(() => {
      count++
      if (count >= chunks) {
        observer.disconnect()
        return
      }
      this.scrollToBottom()
    })
    observer.observe(this.element, { childList: true, subtree: true })
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }
}
