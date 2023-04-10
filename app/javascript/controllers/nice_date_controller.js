import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        const now = new Date()
        const date = new Date(Number(this.element.getAttribute("data-timestamp")) * 1000)

        if (
            date.getDate()     === now.getDate()  &&
            date.getMonth()    === now.getMonth() &&
            date.getFullYear() === now.getFullYear()
        ) {
            this.element.innerText = date.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" })
        } else if (date.getFullYear() === now.getFullYear()) {
            this.element.innerText = date.toLocaleDateString(undefined, { day: "2-digit", month: "2-digit" })
        } else {
            this.element.innerText = date.toLocaleDateString(undefined, { day: "2-digit", month: "2-digit", year: "2-digit" })
        }

        if (this.element.innerText === "Invalid Date") this.element.innerText = ""
    }
}
