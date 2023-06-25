import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        const chat = this.element.parentElement

        document.querySelector(".rounded-top")?.classList.remove("rounded-top")
        document.querySelector(".rounded-bottom")?.classList.remove("rounded-bottom")

        if (chat.classList.contains("selected")) {
            document.querySelector("#chat").src = window.location.origin
        } else {
            let above = chat.previousElementSibling
            const below = chat.nextElementSibling

            if (above === null) above = document.querySelector("#list-header")

            chat.classList.add("selected")
            below.classList.add("rounded-top")
            above.classList.add("rounded-bottom")
        }

        chat.remove()
    }
}
