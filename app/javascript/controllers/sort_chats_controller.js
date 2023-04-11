import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        const chat = this.element.parentElement

        let above = chat.previousElementSibling
        let below = chat.nextElementSibling

        if (above === null) return

        document.querySelector(".rounded-bottom")?.classList.remove("rounded-bottom")
        document.querySelector(".rounded-top")?.classList.remove("rounded-top")

        const timestamp = Number(chat.querySelector(".date").getAttribute("data-timestamp"))

        while (
            above !== null &&
            timestamp > Number(above.querySelector(".date").getAttribute("data-timestamp"))
        ) {
            below = above
            above = above.previousElementSibling
        }

        const list = document.querySelector("#list")
        list.insertBefore(chat, below)

        const selected = list.querySelector(".selected")

        if (selected !== null) {
            above = selected.previousElementSibling
            below = selected.nextElementSibling

            if (above === null) above = document.querySelector("#list-header")

            above.classList.add("rounded-bottom")
            below.classList.add("rounded-top")
        }
    }
}
