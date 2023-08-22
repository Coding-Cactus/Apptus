import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        const now = new Date()
        const date = new Date(Number(this.element.getAttribute("data-timestamp")) * 1000)

        let text = ""
        const parent = this.element.parentNode
        if (parent.classList.contains("msg-info") || parent.classList.contains("system-message")) {
            text = date.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" }) + " "
        }

        if (
            date.getDate()     === now.getDate()  &&
            date.getMonth()    === now.getMonth() &&
            date.getFullYear() === now.getFullYear()
        ) {
            // Today
            this.element.innerText = date.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" })
        } else if (date.getFullYear() === now.getFullYear()) {
            // This Year
            this.element.innerText = text + date.toLocaleDateString(undefined, { day: "2-digit", month: "2-digit" })
        } else {
            // Over a year ago
            this.element.innerText = text + date.toLocaleDateString(undefined, { day: "2-digit", month: "2-digit", year: "2-digit" })
        }

        if (this.element.innerText === "Invalid Date") this.element.innerText = ""
    }
}
