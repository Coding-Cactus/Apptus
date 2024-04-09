import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        const selected = document.querySelector(".chat-preview.selected")
        const messages = document.querySelector("#messages")

        if (
            selected?.querySelector(".unread-count") === this.element
            && messages.scrollHeight - messages.scrollTop - messages.offsetHeight <= 10
        ) {
            selected.querySelector(".unread-count")?.remove()
        }
    }
}
