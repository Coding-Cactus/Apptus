import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        const newMessage = this.element
        const userId = newMessage.getAttribute("data-user-id")

        const previousMessage = this.element?.previousElementSibling
        const previousUserId = previousMessage?.getAttribute("data-user-id")

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

        const chat = this.element.parentElement

        // If message is not from current user
        if (window.getComputedStyle(newMessage).getPropertyValue("flex-direction") === "row") {
            document.querySelector("#mark-as-read").setAttribute("data-enabled", "true")

            // Not enough messages to cause a scroll yet, so send event manually to mark messages as read
            if (chat.scrollHeight === chat.offsetHeight) {
                chat.dispatchEvent(new CustomEvent("scroll"))
            }
        }

        if (chat.scrollHeight - chat.scrollTop - chat.offsetHeight <= this.element.offsetHeight + 10) {
            newMessage.scrollIntoView()
        }
    }
}
