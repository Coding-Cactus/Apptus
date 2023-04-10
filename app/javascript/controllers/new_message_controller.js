import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        const newMessage = this.element
        const userId = newMessage.getAttribute("data-user-id")

        const previousMessage = this.element.previousElementSibling
        const previousUserId = previousMessage.getAttribute("data-user-id")

        if (userId === previousUserId) {
            previousMessage.classList.remove("bottom")

            const pfpFiller = document.createElement("div")
            pfpFiller.classList.add("pfp-filler")

            const triangleFiller = document.createElement("div")
            triangleFiller.classList.add("triangle-filler")

            newMessage.querySelector(".pfp").replaceWith(pfpFiller)
            newMessage.querySelector(".message-and-triangle svg").replaceWith(triangleFiller)
        } else {
            newMessage.classList.add("top")
        }

        newMessage.scrollIntoView()
    }
}
