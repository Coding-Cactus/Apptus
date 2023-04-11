import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        scrollToBottom(this.element)

        this.element.addEventListener("turbo:frame-load", () => { scrollToBottom(this.element) })
    }
}

function scrollToBottom(elem) {
    elem.scrollTop = elem.scrollHeight
}
