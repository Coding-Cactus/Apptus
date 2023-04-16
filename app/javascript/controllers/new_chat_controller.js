import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.element.setAttribute(
            "data-controller",
            this.element.getAttribute("data-controller").replace(/ ?new-chat/, "")
        )

        this.application.getControllerForElementAndIdentifier(this.element, "open-chat").open()
    }
}
