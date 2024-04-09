import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        const selected = document.querySelector(".chat-preview.selected")
        const messages = document.querySelector("#messages")

        this.updateTotalCount(Number(this.element.innerText), 1)

        if (
            selected?.querySelector(".unread-count") === this.element
            && messages.scrollHeight - messages.scrollTop - messages.offsetHeight <= 10
        ) {
            this.element.remove()
        }
    }

    disconnect() {
        this.updateTotalCount(Number(this.element.innerText), -1)
    }

    updateTotalCount(diff, direction) {
        const total_count = Number(document.body.getAttribute("data-total-unread-count"))

        if (direction === -1) diff = Math.min(diff, total_count) // ensure number won't somehow go negative

        const new_total = total_count + direction * diff

        document.body.setAttribute("data-total-unread-count", new_total)

        let new_title = document.title
        if (total_count === 0) {
            new_title = `${new_total} | ` + new_title
        } else {
            new_title = String(new_total) + " | " + new_title.split(" | ").slice(1).join(" | ")
        }

        if (new_total === 0) {
            new_title = new_title.split(" | ").slice(1).join(" | ")
        }

        document.title = new_title
    }
}
