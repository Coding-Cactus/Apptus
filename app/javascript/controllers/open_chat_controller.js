import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    open() {
        document.querySelector(".selected")?.classList.remove("selected")
        document.querySelector(".rounded-top")?.classList.remove("rounded-top")
        document.querySelector(".rounded-bottom")?.classList.remove("rounded-bottom")

        const chat = this.element

        let above = chat.previousElementSibling
        const below = chat.nextElementSibling

        if (above === null) above = document.querySelector("#list-header")

        chat.classList.add("selected")
        below.classList.add("rounded-top")
        above.classList.add("rounded-bottom")
    }
}
