import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.element.setAttribute(
            "data-controller",
            this.element.getAttribute("data-controller").replace(/ ?new-chat/, "")
        )

        const selected = document.querySelector(".chat-preview.selected")

        if (this.element.getAttribute("data-force-open") !== null) {
            this.application.getControllerForElementAndIdentifier(this.element, "open-chat").open()
            this.element.removeAttribute("data-force-open")
        } else if (selected !== null) {
            this.application.getControllerForElementAndIdentifier(selected, "open-chat").open()
        }
    }
}
