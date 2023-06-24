import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["chat", "content"]

    open() {
        document.querySelector(".selected")?.classList.remove("selected")
        document.querySelector(".rounded-top")?.classList.remove("rounded-top")
        document.querySelector(".rounded-bottom")?.classList.remove("rounded-bottom")

        this.selectInSidebar(this.chatTarget)
    }

    // Triggered by being removed from a chat, and #broadcast_remove_to removing the chat from sidebar
    disconnect() {
        console.log(this.chatTarget)

        document.querySelector(".rounded-top")?.classList.remove("rounded-top")
        document.querySelector(".rounded-bottom")?.classList.remove("rounded-bottom")

        if (this.chatTarget.classList.contains("selected")) {
            document.querySelector("#chat").src = window.location.origin
        } else if (!!document.querySelector(".chat-preview.selected")) {
            this.selectInSidebar(document.querySelector(".chat-preview.selected")) // Update rounded corners
        }
    }

    selectInSidebar(chat) {
        let above = chat.previousElementSibling
        const below = chat.nextElementSibling

        if (above === null) above = document.querySelector("#list-header")

        chat.classList.add("selected")
        below.classList.add("rounded-top")
        above.classList.add("rounded-bottom")
    }
}
